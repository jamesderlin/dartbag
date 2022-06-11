/// [Timer] implementations with different behaviors.

import 'dart:async';

import 'package:clock/clock.dart';

/// A periodic [Timer] that automatically stops after a specified amount of
/// time.
//
//// Based on <https://stackoverflow.com/a/72144642/>.
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

  @override
  void cancel() {
    _periodicTimer.cancel();
    _completionTimer.cancel();
  }
}
