/// Utilities to parse objects from [String]s.

// See <https://github.com/dart-lang/dartdoc/issues/1082>
library parse;

/// Tries to parse a [bool] from a [String].
///
/// Returns `true` if the input is "true", "yes", or "1".  Returns `false` if
/// the input is "false", "no", or "0".  In both cases, case and surroudning
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
