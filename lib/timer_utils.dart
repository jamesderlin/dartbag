import 'dart:async';

import 'package:clock/clock.dart';

/// A [Timer] that can be easily restarted.
class RestartableTimer implements Timer {
  Duration _duration;
  void Function() _callback;

  final DateTime _startTime;
  Timer? _timer;

  /// Constructor.
  RestartableTimer(Duration duration, void Function() callback)
      : _duration = duration,
        _callback = callback,
        _startTime = clock.now() {
    restart();
  }

  @override
  bool get isActive => _timer != null;

  @override
  int get tick =>
      clock.now().difference(_startTime).inMicroseconds ~/
      _duration.inMicroseconds;

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Restarts the [RestartableTimer].
  ///
  /// If [duration] or [callback] are not specified, the initial value passed
  /// to the [RestartableTimer.new] will be used.
  void restart({Duration? duration, void Function()? callback}) {
    _duration = duration ?? _duration;
    _callback = callback ?? _callback;

    _timer?.cancel();
    _timer = Timer(_duration, () {
      try {
        _callback();
      } finally {
        _timer = null;
      }
    });
  }
}

/// A periodic [Timer] that automatically stops after a specified amount of
/// time.
// Based on <https://stackoverflow.com/a/72144642/>.
class ExpiringPeriodicTimer implements Timer {
  /// When the timer expires.
  final DateTime _endTime;

  /// The interval between invocations of the [_onTick] callback.
  final Duration _interval;

  /// The callback to invoke periodically with the amount of time left before
  /// the timer expires.
  final void Function(Duration timeLeft) _onTick;

  /// The callback to invoke when the timer expires.
  final void Function()? _onFinish;

  late Timer _periodicTimer;
  late Timer _completionTimer;

  /// Constructor.
  ///
  /// The [ExpiringPeriodicTimer] will expire after the [total] amount of time
  /// has elapsed.  The optional [onFinish] callback will be invoked upon
  /// expiration.
  ///
  /// Until the timer expires, [onTick] will be invoked periodically every
  /// [interval] with the amount of time left before expiration.
  ExpiringPeriodicTimer({
    required Duration total,
    required Duration interval,
    required void Function(Duration timeLeft) onTick,
    void Function()? onFinish,
  })  : _endTime = clock.now().add(total),
        _interval = interval,
        _onTick = onTick,
        _onFinish = onFinish {
    // Schedule the periodic [Timer] first to try to ensure that it fires first
    // if it coincides with the completion [Timer].
    _periodicTimer = Timer.periodic(_interval, (_) {
      _onTick(_endTime.difference(clock.now()));
    });
    _completionTimer = Timer(total, () {
      _periodicTimer.cancel();
      _onFinish?.call();
    });
  }

  @override
  bool get isActive => _completionTimer.isActive;

  @override
  int get tick => _periodicTimer.tick;

  /// Cancels the timer.
  @override
  void cancel() {
    _periodicTimer.cancel();
    _completionTimer.cancel();
  }
}
