/// Utilities for collection types and [Iterable]s.
library;

import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart' as collection;

import 'comparable.dart';

/// Recursively flattens all nested [Iterable]s into a single [Iterable]
/// sequence.
Iterable<T> flattenDeep<T>(Iterable<Object?> list) sync* {
  for (var element in list) {
    if (element is! Iterable) {
      yield element as T;
    } else {
      yield* flattenDeep(element);
    }
  }
}

/// Like [`zip`] or [`IterableZip`] except that `zip_longest` stops only after
/// the longest `Iterable` is exhausted instead of the shortest.
///
/// All [Iterable]s shorter than the longest [Iterable] will be padded with
/// [fillValue].
///
/// If any of the input [Iterable]s is infinitely long, the returned [Iterable]
/// also will be infinitely long.
///
/// [zip]: https://pub.dev/documentation/quiver/latest/quiver.iterables/zip.html
///
// N.B.: It'd be nice if we could leverage [zip] or [IterableZip] by using the
// [Iterable.padRight] extension method, but doing so would require determining
// the length of the input [Iterable]s, which cannot work on ones that are
// infinitely long.
Iterable<List<E>> zipLongest<E>(
  Iterable<Iterable<E>> iterables,
  E fillValue,
) sync* {
  var iterators = [for (var iterable in iterables) iterable.iterator];

  while (true) {
    var exhaustedCount = 0;
    var current = <E>[];
    for (var i = 0; i < iterators.length; i += 1) {
      if (iterators[i].moveNext()) {
        current.add(iterators[i].current);
        continue;
      }

      exhaustedCount += 1;
      if (exhaustedCount == iterators.length) {
        return;
      }
      current.add(fillValue);
    }

    yield current;
  }
}

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
  ///
  /// To use `sortWithKey` with keys that are easily comparable with a custom
  /// comparison function but that do not implement [Comparable], use
  /// [ComparableWrapper].
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

  /// Returns `true` if `this` starts with [other] in order.
  bool startsWith(Iterable<E> other) {
    var iterator = this.iterator;
    var otherIterator = other.iterator;

    while (true) {
      var hasElementsLeft = iterator.moveNext();
      var otherHasElementsLeft = otherIterator.moveNext();

      if (!otherHasElementsLeft) {
        return true;
      }
      if (!hasElementsLeft) {
        return false;
      }
      if (iterator.current != otherIterator.current) {
        return false;
      }
    }
  }

  /// Pads elements to the beginning of this [Iterable] to make it have the
  /// specified length.
  ///
  /// If the [length] of this [Iterable] is already [totalLength] or greater,
  /// returns this [Iterable].
  Iterable<E> padLeft(int totalLength, {required E padValue}) {
    if (totalLength <= length) {
      return this;
    }

    return Iterable<E>.generate(
      totalLength - length,
      (_) => padValue,
    ).followedBy(this);
  }

  /// Pads elements to the end of this [Iterable] to make it have the specified
  /// length.
  ///
  /// If the [length] of this [Iterable] is already [totalLength] or greater,
  /// returns this [Iterable].
  Iterable<E> padRight(int totalLength, {required E padValue}) {
    if (totalLength <= length) {
      return this;
    }

    return followedBy(
      Iterable<E>.generate(
        totalLength - length,
        (_) => padValue,
      ),
    );
  }
}

/// Provides a [sort] extension method on [LinkedHashMap].
extension SortMap<K, V> on LinkedHashMap<K, V> {
  /// Sorts a [LinkedHashMap] according to a specified [Comparator] on
  /// [MapEntry]s.
  ///
  /// Note that since extension methods are syntactic sugar that depend on
  /// *static* (not *runtime*) types, this extension method requires that the
  /// receiver be declared as (or casted to) a [LinkedHashMap] and not as a
  /// general [Map].
  void sort(int Function(MapEntry<K, V> a, MapEntry<K, V> b) compare) {
    var entries = this.entries.toList()..sort(compare);
    clear();
    addEntries(entries);
  }
}

/// Combines an [Iterable] of [Map]s into a single [Map] with [List]s of the
/// corresponding values.
///
/// Example:
/// ```dart
/// var merged = mergeMaps([
///   {'a': 1, 'b': 2},
///   {'a': 10, 'b': 20, 'c': 30},
///   {'a': 100},
/// ]);
/// print(merged); // {a: [1, 10, 100], b: [2, 20], c: [30]}
///
/// var foldedValues = {
///   for (var entry in merged.entries)
///     entry.key: entry.value.fold(0, (a, b) => a + b),
/// };
/// print(foldedValues); // {a: 111, b: 22, c: 30}
///
/// var earliestValues = {
///   for (var entry in merged.entries) entry.key: entry.value.first,
/// };
/// print(earliestValues); // {a: 1, b: 2, c: 30}
/// ```
Map<K, List<V>> mergeMaps<K, V>(Iterable<Map<K, V>> maps) {
  var result = <K, List<V>>{};
  for (var map in maps) {
    for (var entry in map.entries) {
      (result[entry.key] ??= <V>[]).add(entry.value);
    }
  }
  return result;
}

/// Provides a [wait] extension property on a [Map] with [Future] values.
extension FutureMap<K, V> on Map<K, Future<V>> {
  /// Creates a `Map<K, V>` from a `Map<K, Future<V>>`.
  ///
  /// Like [FutureIterable<T>.wait] but waits on [Map] values (in parallel if
  /// possible).
  ///
  /// The returned [Future] will complete only after *all* [Future] values have
  /// completed.  If any of those [Future]s fails, completes with a
  /// [ParallelMapWaitError].
  Future<Map<K, V>> get wait async {
    // Copy the keys now in case this `Map` is mutated while waiting.
    var keysCopy = [...keys];
    try {
      var awaitedValues = await values.wait;
      assert(keysCopy.length == awaitedValues.length);
      return Map.fromIterables(keysCopy, awaitedValues);

      // ignore: avoid_catching_errors
    } on ParallelWaitError<List<V?>, List<AsyncError?>> catch (e) {
      assert(keysCopy.length == e.values.length);
      assert(keysCopy.length == e.errors.length);

      var values = <K, V>{};
      var errors = <K, AsyncError>{};

      for (var i = 0; i < keysCopy.length; i += 1) {
        var error = e.errors[i];
        if (error == null) {
          values[keysCopy[i]] = e.values[i] as V;
        } else {
          errors[keysCopy[i]] = error;
        }
      }

      throw ParallelMapWaitError(values, errors);
    }
  }
}

/// An error thrown when [FutureMap.wait] fails.
///
/// Similar to [ParallelWaitError] but with the shape of a [Map].
///
/// Unlike [ParallelWaitError], [values] will not store `null` for values
/// that failed, and [errors] will not store `null` for values that succeeded.
/// Instead, those entries simply will not exist in the returned [Map]s.
class ParallelMapWaitError<K, V> extends Error {
  /// A [Map] of keys to successfully completed values.
  ///
  /// The returned [Map] will contain entries only for [Future]s that
  /// successfully completed and not for ones that failed.
  final Map<K, V> values;

  /// A [Map] of keys to errors from failed [Future]s.
  ///
  /// The returned [Map] will contain entries only for failed [Future]s and not
  /// for ones that successfully completed.
  final Map<K, AsyncError> errors;

  /// Constructor.
  ParallelMapWaitError(this.values, this.errors);
}
