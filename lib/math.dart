/// Mathematical-related utilities.
library;

import 'dart:math' as math;

/// Returns the least common multiple of two integers.
///
/// The result is always non-negative.
int lcm(int x, int y) {
  if (x == 0 || y == 0) {
    return 0;
  }

  return ((x ~/ x.gcd(y)) * y).abs();
}

/// Provides miscellaneous extension methods on [int].
extension IntUtils on int {
  /// Rounds a non-negative integer down to nearest multiple of `multipleOf`
  /// that is less-than-or-equal-to this integer.
  ///
  /// `multipleOf` must be positive.
  int floorToMultipleOf(int multipleOf) {
    assert(this >= 0);
    assert(multipleOf > 0);
    return (this ~/ multipleOf) * multipleOf;
  }

  /// Rounds a non-negative integer up to nearest multiple of `multipleOf` that
  /// is greater-than-or-equal-to this integer.
  ///
  /// `multipleOf` must be positive.
  int ceilToMultipleOf(int multipleOf) {
    assert(this >= 0);
    assert(multipleOf > 0);
    return (this + multipleOf - 1).floorToMultipleOf(multipleOf);
  }

  /// Rounds a non-negative integer to the nearest multiple of `multipleOf`.
  ///
  /// `multipleOf` must be positive.
  int roundToMultipleOf(int multipleOf) {
    assert(this >= 0);
    assert(multipleOf > 0);
    return (this + multipleOf ~/ 2).floorToMultipleOf(multipleOf);
  }
}

/// Miscellaneous utility methods for [Rectangle].
extension RectangleUtils<T extends num> on math.Rectangle<T> {
  /// Returns the center of the [Rectangle].
  math.Point<num> get center =>
      math.Point<num>(left + width / 2, top + height / 2);
}
