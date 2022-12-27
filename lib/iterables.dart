/// Utilities for [List]s and other [Iterable]s.

import 'package:collection/collection.dart' as collection;

/// Extension methods on [List] that do work in-place.
extension InPlaceOperations<E> on List<E> {
  /// Reverses the [List] in-place.
  void reverse() => collection.reverse(this);

  /// Rotates the [List] in-place in O(n) time and O(1) space.
  ///
  /// If [shiftAmount] is positive, rotates elements to the left.  If negative,
  /// rotates elements to the right.
  ///
  /// Rotates elements in the range [start] (inclusive) to [end] (exclusive).
  /// If unspecified, [start] defaults to 0 and [end] defaults to the length of
  /// the [List].
  void rotateLeft(int shiftAmount, {int? start, int? end}) {
    start ??= 0;
    end ??= length;
    assert(start >= 0);
    assert(start <= end);
    assert(end <= length);

    var rotatedLength = end - start;
    if (rotatedLength == 0) {
      // Nothing to rotate.
      return;
    }

    shiftAmount %= rotatedLength;
    assert(shiftAmount >= 0);

    var splitIndex = start + rotatedLength - shiftAmount;
    reverseRange(start, end);
    reverseRange(start, splitIndex);
    reverseRange(splitIndex, end);
  }
}

int _compareKeys<K extends Comparable<Object>, V>(
  MapEntry<K, V> a,
  MapEntry<K, V> b,
) =>
    a.key.compareTo(b.key);

/// Provides a [sortWithKey] extension method on [List].
extension SortWithKeyExtension<E> on List<E> {
  /// Sorts this [List] according to the computed sort key.
  ///
  /// The sort keys are cached, so this can be much more time-efficient (at the
  /// expense of space) than using [sort] with a custom comparison callback if
  /// comparisons are expensive.
  ///
  /// [K] intentionally extends from [Comparable<Object>] and not from
  /// `Comparable<K>` so that this works with [int] and [double] types (which
  /// otherwise would not work because [int] and [double] implement
  /// `Comparable<num>`).
  void sortWithKey<K extends Comparable<Object>>(K Function(E) key) {
    final keyValues = [
      for (var element in this) MapEntry(key(element), element),
    ]..sort(_compareKeys);

    // Copy back to mutate the original [List].
    assert(length == keyValues.length);
    for (var i = 0; i < length; i += 1) {
      this[i] = keyValues[i].value;
    }
  }

  /// A version of [sortWithKey] that allows the sort key to be computed
  /// asynchronously.
  Future<void> sortWithAsyncKey<K extends Comparable<Object>>(
    Future<K> Function(E) key,
  ) async {
    var keys = await Future.wait([for (var element in this) key(element)]);

    assert(length == keys.length);
    final keyValues = [
      for (var i = 0; i < length; i += 1) MapEntry(keys[i], this[i]),
    ]..sort(_compareKeys);

    // Copy back to mutate the original [List].
    for (var i = 0; i < length; i += 1) {
      this[i] = keyValues[i].value;
    }
  }
}

/// Miscellaneous utility methods for [Iterable].
extension IterableUtils<E> on Iterable<E> {
  /// Iterates over all elements, discarding the results.
  ///
  /// Useful only if iterating has side-effects, which is uncommon.
  void drain() {
    for (void _ in this) {}
  }
}

/// Compares two iterables of [Comparable] elements in a manner similar to
/// string comparison.
///
/// For two iterables `iterable1` and `iterable2`, `iterable1` is considered to
/// be less than `iterable2` if and only if:
/// * For some *k*, `iterable1[k].compareTo(iterable2[k]) < 0` such that for
///   all *i* where `0 <= i < k`, `iterable1[i].compareTo(iterable2[i]) == 0`.
/// * `iterable1.length < iterable2.length` and
///   `iterable1[i].compareTo(iterable2[i]) == 0` for all
///   `i < iterable1.length`.
int compareIterables<E extends Comparable<Object>>(
  Iterable<E> iterable1,
  Iterable<E> iterable2,
) {
  var iterator1 = iterable1.iterator;
  var iterator2 = iterable2.iterator;
  while (true) {
    var isEmpty1 = !iterator1.moveNext();
    var isEmpty2 = !iterator2.moveNext();
    if (isEmpty1 || isEmpty2) {
      if (isEmpty1 && isEmpty2) {
        return 0;
      } else if (isEmpty1) {
        return -1;
      } else {
        return 1;
      }
    }

    var value1 = iterator1.current;
    var value2 = iterator2.current;
    var comparisonResult = value1.compareTo(value2);
    if (comparisonResult != 0) {
      return comparisonResult;
    }
  }
}
