import 'dart:math' as math;

import 'list_extensions.dart';

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

/// Miscellaneous utility methods for [math.Random].
extension RandomUtils on math.Random {
  /// Returns a random intenger in the range \[`low`, `high`).
  int nextIntFrom(int low, int high) => low + nextInt(high - low);
}

/// Shuffles a [List] lazily.
///
/// Examples:
/// ```dart
/// var list = [for (var i = 0; i < 1000; i += 1) i];
///
/// // Draw 5 random elements from `list`.  The rest of `list` will contain the
/// // remaining elements in an indeterminate order.
/// var iterator = lazyShuffler(list).iterator;
/// for (var i = 0; i < 5 && iterator.moveNext(); i += 1) {
///   print(iterator.current);
/// }
///
/// // Alternatively:
/// var i = 0;
/// for (var element in lazyShuffler(list)) {
///   if (i == 5) {
///     break;
///   }
///   print(element);
/// }
///
/// // Or if resuming iteration later is unnecessary:
/// lazyShuffler(list).take(5).forEach(print);
/// ```
/// Since advancing the iterator mutates `list`, `list[i]` in the example
/// above would the same value as `iterator.current`.
Iterable<T> lazyShuffler<T>(List<T> list, {math.Random? random}) sync* {
  random ??= math.Random();
  for (var nextIndex = 0; nextIndex < list.length; nextIndex += 1) {
    var i = random.nextIntFrom(nextIndex, list.length);
    list.swap(nextIndex, i);
    yield list[nextIndex];
  }
}

/// Tries to parse a [bool] from a [String].
///
/// Returns `true` if the input is "true", "yes", or "1".  Returns `false` if
/// the input is "false", "no", or "0".  In both cases, case and surroudning
/// whitespace are ignored.
///
/// Returns `null` if the input is not recognized.
bool? tryParseBool(String value) {
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

// ignore: public_member_api_docs
extension ParseEnum<T extends Enum> on List<T> {
  /// Tries to parse an `enum` constant` from its name.
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
  T? tryParse(String name, {bool caseSensitive = false}) {
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

/// Miscellaneous utility methods for [Uri].
extension UriUtils on Uri {
  /// Adds or replaces query parameters.
  ///
  /// The values in the [queryParameters] [Map] must be [String]s or
  /// [Iterable<String>]s.  See [Uri.new] for details.
  Uri updateQueryParameters(Map<String, dynamic> queryParameters) {
    return replace(
      queryParameters: {
        ...this.queryParameters,
        ...queryParameters,
      },
    );
  }
}

/// Miscellaneous utility methods for [Rectangle].
extension RectangleUtils<T extends num> on math.Rectangle<T> {
  /// Returns the center of the [Rectangle].
  math.Point<num> get center =>
      math.Point<num>(left + width / 2, top + height / 2);
}
