/// Utilities for [Comparable] objects.
library;

import 'package:basics/comparable_basics.dart';

/// Provides miscellaneous extension methods on [Comparable].
extension ComparableUtils<T> on Comparable<T> {
  /// Clamps this [Comparable] to be within the range \[`low`, `high`\].
  T clamp(T low, T high) =>
      (this < low) ? low : ((this > high) ? high : (this as T));
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

/// Wraps a value in a [Comparable] interface with a specified comparison
/// function.
///
/// For example, this can be used to combine [SortWithKeyExtension.sortWithKey]
/// and [compareIterables]:
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
