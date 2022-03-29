// ignore: public_member_api_docs
extension TryAsExtension on Object? {
  /// Attempts to cast this to `T`, returning `null` on failure.
  ///
  /// This is a workaround until `as?` is implemented:
  /// <https://github.com/dart-lang/language/issues/399>
  T? tryAs<T>() {
    final self = this;
    return (self is T) ? self : null;
  }
}

// ignore: public_member_api_docs
extension StaticTypeExtension<T> on T {
  /// Returns the static type of this object.
  Type get staticType => T;
}

/// Recursively flattens all nested [Iterable]s in specified [Iterable] to a
/// single [Iterable] sequence.
Iterable<T> flattenDeep<T>(Iterable<Object?> list) sync* {
  for (var element in list) {
    if (element is! Iterable) {
      yield element as T;
    } else {
      yield* flattenDeep(element);
    }
  }
}

/// Returns a [Duration] as a human-readable string.
///
/// Example outputs:
/// 1d2h34m56.789s
/// 1d
/// 1d58s
/// 1d0.2s
String readableDuration(Duration duration) {
  if (duration.inMicroseconds == 0) {
    return '0s';
  }

  var sign = '';
  if (duration.isNegative) {
    sign = '-';
    duration = -duration;
  }

  var days = duration.inDays;
  var hours = duration.inHours % Duration.hoursPerDay;
  var minutes = duration.inMinutes % Duration.minutesPerHour;
  var seconds = duration.inSeconds % Duration.secondsPerMinute;
  var microseconds = duration.inMicroseconds % Duration.microsecondsPerSecond;

  var secondsString = '';
  if (microseconds > 0) {
    var fractionalSecondsString =
        '$microseconds'.padLeft(6, '0').replaceAll(RegExp(r'0+$'), '');
    secondsString = '$seconds.${fractionalSecondsString}s';
  } else if (seconds > 0) {
    secondsString = '${seconds}s';
  }

  var components = <String>[
    sign,
    if (days > 0) '${days}d',
    if (hours > 0) '${hours}h',
    if (minutes > 0) '${minutes}m',
    secondsString,
  ];

  return components.join();
}

// ignore: public_member_api_docs
extension ReadableDuration on Duration {
  /// An extension version of [readableDuration].
  String toReadableString() => readableDuration(this);
}

// ignore: public_member_api_docs
extension PadStringExtension on int {
  /// Returns a string representation of this [int], left-padded with zeroes if
  /// necessary to have the specified number of digits.
  String padDigits(int minimumDigits) => toString().padLeft(minimumDigits, '0');
}

/// Times the specified operation.
Duration timeOperation(void Function() operation) {
  var stopwatch = Stopwatch()..start();
  operation();
  return stopwatch.elapsed;
}
