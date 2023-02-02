/// Utilities for collection types and [Iterable]s.
library;

import 'dart:collection';
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

/// Wraps a value in a [Comparable] interface with a specified comparison
/// function.
///
/// For example, this can be used to combine [sortWithKey] and
/// [compareIterables]:
///
/// ```dart
/// class Name {
///   String surname;
///   String givenName;
///
///   Name(this.surname, this.givenName);
/// }
///
/// void main() {
///   var names = [
///     Name('Smith', 'Jane'),
///     Name('Doe', 'John'),
///     Name('Doe', 'Jane'),
///     Name('Galt', 'John'),
///   ];
///
///   names.sortWithKey(
///     (name) => ComparableWrapper(
///       [name.surname, name.givenName],
///       compareIterables,
///     ),
///   );
/// }
/// ```
class ComparableWrapper<T> implements Comparable<ComparableWrapper<T>> {
  /// The wrapped value to compare.
  final T value;

  /// The comparison function used to compare [value] to another [T] instance.
  final Comparator<T> compare;

  /// Constructor.
  ComparableWrapper(this.value, this.compare);

  @override
  int compareTo(ComparableWrapper<T> other) => compare(this.value, other.value);
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
///
/// This can be used to sort a `List` of objects by multiple properties.  For
/// example:
///
/// ```dart
/// var items = getItems();
/// items.sort(
///   (item1, item2) => compareIterables(
///     [item1.majorProperty, item1.minorProperty],
///     [item2.majorProperty, item2.minorProperty],
///   ),
/// );
/// ```
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
