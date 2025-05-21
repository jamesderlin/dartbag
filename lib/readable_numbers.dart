/// Makes numbers more human-readable by adding SI prefixes and units.
library;

import 'dart:math' as math;

import 'math.dart';
import 'misc.dart';

const _siMacroPrefixes = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];
const _siMicroPrefixes = ['m', '\u03BC', 'n', 'p', 'f', 'a', 'z', 'y'];

final _binaryMacroPrefixes = [
  '',
  for (var prefix in _siMacroPrefixes.skip(1)) '${prefix}i',
];

/// Helper function to [readableNumber] to handle non-zero numbers with an
/// absolute value strictly less than 1.
String _readableMicroNumber(
  num n, {
  required int precision,
  required String unit,
}) {
  var absoluteValue = n.abs();
  assert(absoluteValue > 0 && absoluteValue < 1);

  const multiplier = 1000;
  late String numberString;

  var i = 0;
  while (true) {
    if (i == _siMicroPrefixes.length) {
      numberString = n.toStringAsExponential(precision);
      break;
    }

    n *= multiplier;

    if (n.abs() >= 1) {
      numberString = n.toStringAsFixed(precision);
      break;
    }

    i += 1;
  }

  var prefix = _siMicroPrefixes[math.min(i, _siMicroPrefixes.length - 1)];
  return '$numberString $prefix$unit';
}

/// Returns the specified number as a human-readable string.
///
/// [precision] specifies the number of fractional digits to show after the
/// decimal point. [precision] must be non-negative.
///
/// [unit], if specified, will be appended to the resulting string.
///
/// If [binary] is true, `readableNumber` will prefer binary IEC prefixes over
/// SI prefixes. [binary] will be ignored for numbers with an absolute value
/// less than 1.
///
/// Examples:
/// ```dart
/// readableNumber(1, unit: 'B'); // '1 B'
/// readableNumber(1000); // '1 K'
/// readableNumber(1234567, precision: 2, unit: 'B'); // '1.23 MB'
/// readableNumber(1234567, precision: 2, unit: 'B', binary: true); // '1.18 MiB'
/// readableNumber(0.1, unit: 'g'); // '100 mg'
/// ```
String readableNumber(
  num n, {
  int precision = 0,
  String unit = '',
  bool binary = false,
}) {
  var absoluteValue = n.abs();
  if (absoluteValue > 0 && absoluteValue < 1) {
    return _readableMicroNumber(n, precision: precision, unit: unit);
  }

  var multiplier = binary ? 1024 : 1000;
  var prefixes = binary ? _binaryMacroPrefixes : _siMacroPrefixes;
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

/// Provides a [toReadableString] extension method on [num].
extension ReadableNumber on num {
  /// An extension version of [readableNumber].
  String toReadableString({
    int precision = 0,
    String unit = '',
    bool binary = false,
  }) => readableNumber(this, precision: precision, unit: unit, binary: binary);
}

/// Returns a [Duration] as a human-readable string.
///
/// [precision] specifies the *maximum* number of fractional digits to show
/// after the decimal point in the number of seconds.  If `null`, the maximum
/// precision will be used.
///
/// Trailing zeroes from any fractional portion are always discarded.
///
/// Example outputs:
/// ```dart
/// 1d2h34m56.789s
/// 1d
/// 2h58s
/// 2h0.2s
/// ```
String readableDuration(Duration duration, {int? precision}) {
  if (duration.inMicroseconds == 0) {
    return '0s';
  }

  var sign = '';
  if (duration.isNegative) {
    sign = '-';
    duration = -duration;
  }

  if (precision != null && precision < 6) {
    if (precision < 0) {
      throw ArgumentError(
        'readableDuration: precision must be non-negative.',
      );
    }
    duration = Duration(
      microseconds: duration.inMicroseconds.roundToMultipleOf(
        math.pow(10, 6 - precision) as int,
      ),
    );
  }

  var days = duration.inDays;
  var hours = duration.inHours % Duration.hoursPerDay;
  var minutes = duration.inMinutes % Duration.minutesPerHour;
  var seconds = duration.inSeconds % Duration.secondsPerMinute;
  var microseconds = duration.inMicroseconds % Duration.microsecondsPerSecond;

  var secondsString = '';
  if (microseconds > 0) {
    // Strip off trailing zeroes from the fractional portion.
    var fractionalSecondsString = microseconds
        .padLeft(6)
        .replaceAll(RegExp(r'0+$'), '');
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

/// Provides a [toReadableString] extension method on [Duration].
extension ReadableDuration on Duration {
  /// An extension version of [readableDuration].
  String toReadableString({int? precision}) =>
      readableDuration(this, precision: precision);
}
