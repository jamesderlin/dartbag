/// [Timer] implementations with different behaviors.
library;

import 'dart:async';

import 'package:clock/clock.dart';

/// A periodic [Timer] that automatically stops after a specified amount of
/// time.
///
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
  /// has elapsed.  The optional [_onFinish] callback will be invoked upon
  /// expiration.
  ///
  /// Until the timer expires, [_onTick] will be invoked periodically every
  /// [_interval] with the amount of time left before expiration.
  new({
    required Duration total,
    required this._interval,
    required this._onTick,
    this._onFinish,
  }) : _endTime = clock.now().add(total) {
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
