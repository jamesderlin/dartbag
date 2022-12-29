/// Utilities to parse objects from [String]s.

// See <https://github.com/dart-lang/dartdoc/issues/1082>
library parse;

import 'misc.dart';

/// Tries to parse a [bool] from a [String].
///
/// Returns `true` if the input is "true", "yes", or "1".  Returns `false` if
/// the input is "false", "no", or "0".  In both cases, case and surrounding
/// whitespace are ignored.
///
/// Returns `null` if the input is not recognized.
bool? tryParseBool(String? value) {
  if (value == null) {
    return null;
  }

  const trueStrings = {'true', 'yes', '1'};
  const falseStrings = {'false', 'no', '0'};
  value = value.trim().toLowerCase();
  if (trueStrings.contains(value)) {
    return true;
  } else if (falseStrings.contains(value)) {
    return false;
  }
  return null;
}

/// A wrapper around [int.tryParse] that accepts a `null` argument.
int? tryParseInt(String? value, {int? radix}) =>
    value == null ? null : int.tryParse(value, radix: radix);

/// A wrapper around [double.tryParse] that accepts a `null` argument.
double? tryParseDouble(String? value) =>
    value == null ? null : double.tryParse(value);

/// Provides a [tryParse] extension method on a [List] of `enum` values.
extension ParseEnum<T extends Enum> on List<T> {
  /// Tries to parse an `enum` constant from its name.
  ///
  /// Ignores surrounding whitespace.
  ///
  /// Returns `null` if unrecognized.
  ///
  /// Example:
  /// ```dart
  /// enum Color { red, green, blue }
  ///
  /// Color.values.tryParse('blue'); // Color.blue
  /// ```
  T? tryParse(String? name, {bool caseSensitive = false}) {
    if (name == null) {
      return null;
    }

    name = name.trim();
    if (!caseSensitive) {
      name = name.toLowerCase();
    }

    for (var element in this) {
      var enumName = element.name;
      if (!caseSensitive) {
        enumName = enumName.toLowerCase();
      }

      if (enumName == name) {
        return element;
      }
    }
    return null;
  }
}

final _durationRegExp = RegExp(
  r'^'
  r'(?<sign>[+-])?'
  r'(?:(?<days>\d+):)?'
  r'(?<hours>\d+):'
  r'(?<minutes>\d+):'
  r'(?<seconds>\d+).'
  r'(?<subseconds>\d+)'
  r'$',
);

final _readableDurationRegExp = RegExp(
  r'^'
  r'(?<sign>[+-])?'
  r'(?:(?<days>\d+)[Dd])?'
  r'(?:(?<hours>\d+)[Hh])?'
  r'(?:(?<minutes>\d+)[Mm])?'
  r'(?:'
  r'(?<seconds>\d+)'
  r'(?:\.(?<subseconds>\d+))?'
  r'[Ss])?'
  r'$',
);

/// Tries to parse a [Duration] from a [String].
///
/// The string must be in the same format used by either [Duration.toString]
/// (e.g. `'1:23:45.123456'`) or [readableDuration].
Duration? tryParseDuration(String? value) {
  if (value == null) {
    return null;
  }

  value = value.trim();
  if (value.isEmpty) {
    return null;
  }

  var match = _durationRegExp.firstMatch(value) ??
      _readableDurationRegExp.firstMatch(value);
  if (match == null) {
    return null;
  }

  var isNegative = match.namedGroup('sign') == '-';

  var daysString = match.namedGroup('days');
  var hoursString = match.namedGroup('hours');
  var minutesString = match.namedGroup('minutes');
  var secondsString = match.namedGroup('seconds');
  var subsecondsString = match.namedGroup('subseconds');

  var days = (daysString == null) ? 0 : int.parse(daysString);
  var hours = (hoursString == null) ? 0 : int.parse(hoursString);
  var minutes = (minutesString == null) ? 0 : int.parse(minutesString);
  var seconds = (secondsString == null) ? 0 : int.parse(secondsString);

  var microseconds = 0;
  if (subsecondsString != null) {
    const microsecondDigits = 6;
    const fixedLength = microsecondDigits + 1;
    microseconds = int.parse(
          subsecondsString.padRight(fixedLength, '0').substring(0, fixedLength),
        ).roundToMultipleOf(10) ~/
        10;
  }

  var duration = Duration(
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    microseconds: microseconds,
  );
  return isNegative ? -duration : duration;
}
