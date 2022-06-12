/// Utilities for [List]s and other [Iterable]s.

import 'package:collection/collection.dart' as collection;

/// Extension methods on [List] that do work in-place.
extension InPlaceOperations<E> on List<E> {
  /// Reverses the [List] in-place.
  void reverse() => collection.reverse(this);

  /// Rotates the [List] in-place.
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

class _SortableKeyPair<T, K extends Comparable<Object>>
    implements Comparable<_SortableKeyPair<T, K>> {
  _SortableKeyPair(this.original, this.key);

  final T original;
  final K key;

  @override
  int compareTo(_SortableKeyPair<T, K> other) => key.compareTo(other.key);
}

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
    final keyPairs = [
      for (var element in this) _SortableKeyPair(element, key(element)),
    ]..sort();

    // Copy back to mutate the original [List].
    assert(length == keyPairs.length);
    for (var i = 0; i < length; i += 1) {
      this[i] = keyPairs[i].original;
    }
  }

  /// A version of [sortWithKey] that allows the sort key to be computed
  /// asynchronously.
  Future<void> sortWithAsyncKey<K extends Comparable<Object>>(
    Future<K> Function(E) key,
  ) async {
    var keys = await Future.wait([for (var element in this) key(element)]);

    assert(length == keys.length);
    final keyPairs = [
      for (var i = 0; i < length; i += 1) _SortableKeyPair(this[i], keys[i]),
    ]..sort();

    // Copy back to mutate the original [List].
    for (var i = 0; i < length; i += 1) {
      this[i] = keyPairs[i].original;
    }
  }
}

/// Miscellaneous utility methods for [Iterable].
extension IterableUtils<E> on Iterable<E> {
  /// Iterates over all elements, discarding the results.
  ///
  /// Useful only if iterating has side-effects, which is uncommon.
  void drain() {
    // ignore: no_leading_underscores_for_local_identifiers, https://github.com/dart-lang/linter/issues/3126
    for (void _ in this) {}
  }
}
