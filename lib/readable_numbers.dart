const _siPrefixes = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];
final _binaryPrefixes = [
  '',
  for (var prefix in _siPrefixes.skip(1)) '${prefix}i',
];

/// Returns the specified number as a human-readable string.
String readableNumber(
  num n, {
  int precision = 0,
  String unit = '',
  bool binary = false,
}) {
  var multiplier = binary ? 1024 : 1000;
  var prefixes = binary ? _binaryPrefixes : _siPrefixes;
  var space = ' ';
  var i = 0;
  while (true) {
    if (n.abs() < multiplier) {
      break;
    }
    i += 1;
    if (i == prefixes.length) {
      // Use the largest prefix we have.
      i -= 1;
      break;
    }

    n /= multiplier;
  }

  if (prefixes[i].isEmpty && unit.isEmpty) {
    // Avoid a trailing space.
    space = '';
  }
  return '${n.toStringAsFixed(precision)}$space${prefixes[i]}$unit';
}

// ignore: public_member_api_docs
extension ReadableNumber on num {
  /// An extension version of [readableNumber].
  String toReadableString({
    int precision = 0,
    String unit = '',
    bool binary = false,
  }) =>
      readableNumber(this, precision: precision, unit: unit, binary: binary);
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
