/// Miscellaneous utilities.

import 'dart:math' as math;

/// Provides a [chainIf] extension method on all objects.
extension ChainIf<T> on T {
  /// Returns `this` if [shouldChain] is true, `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// var items = Set<int>.of([1, 2, 3]..chainIf(shouldShuffle)?.shuffle());
  /// ```
  // ignore: avoid_positional_boolean_parameters, https://github.com/dart-lang/linter/issues/1638
  T? chainIf(bool shouldChain) => shouldChain ? this : null;
}

/// Provides a [tryAs] extension method on all objects.
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

/// A basic wrapper around another type.
class Boxed<T> {
  /// The wrapped value.
  T value;

  // ignore: public_member_api_docs
  Boxed(this.value);
}

/// An output parameter.
///
/// Example:
/// ```dart
/// void divmod(
///   int dividend,
///   int divisor, {
///   required OutputParameter<int> quotient,
///   required OutputParameter<int> remainder,
/// }) {
///   assert(divisor != 0);
///   quotient.value = dividend ~/ divisor;
///   remainder.value = dividend.remainder(divisor);
/// }
///
/// void main() {
///   var quotient = OutputParameter<int>(0);
///   var remainder = OutputParameter<int>(0);
///   divmod(13, 5, quotient: quotient, remainder: remainder);
///   print('13 / 5 = ${quotient.value}R${remainder.value}');
/// }
/// ```
typedef OutputParameter<T> = Boxed<T>;

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

/// Provides miscellaneous extension methods on [int].
extension IntUtils on int {
  /// Returns a string representation of this [int], left-padded with zeroes if
  /// necessary to have the specified minimum number of characters.
  String padDigits(int minimumWidth) {
    if (this < 0) {
      var padded = (-this).padDigits(minimumWidth - 1);
      return '-$padded';
    }
    return toString().padLeft(minimumWidth, '0');
  }

  /// Rounds a non-negative integer to the nearest multiple of `multipleOf`.
  ///
  /// `multipleOf` must be positive.
  int roundToMultipleOf(int multipleOf) {
    assert(this >= 0);
    assert(multipleOf > 0);
    return (this + multipleOf ~/ 2) ~/ multipleOf * multipleOf;
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

/// Provides an [implies] extension method on [bool].
extension ImpliesExtension on bool {
  /// Returns whether this [bool] [logically implies][1] [consequence].
  ///
  /// Given two boolean expressions *p* and *q*, the results of "*p* implies
  /// *q*"" (denoted as *p &rarr; q*) are shown by the following truth table:
  ///
  /// |  p  |  q  | p &rarr; q |
  /// |:---:|:---:|:----------:|
  /// |  T  |  T  | T          |
  /// |  T  |  F  | F          |
  /// |  F  |  T  | T          |
  /// |  F  |  F  | F          |
  ///
  /// <style>table, th, td { border: 1px solid; border-collapse: collapse; padding: 1ex; }</style>
  ///
  /// [1]: https://simple.wikipedia.org/wiki/Implication_(logic)
  // ignore: avoid_positional_boolean_parameters, https://github.com/dart-lang/linter/issues/1638
  bool implies(bool consequence) => !this || consequence;
}
