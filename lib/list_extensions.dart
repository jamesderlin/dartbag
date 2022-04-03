/// Extension methods on [List] that do work in-place.
extension InPlaceOperations<T> on List<T> {
  /// Swaps two elements.
  void swap(int i, int j) {
    var temp = this[i];
    this[i] = this[j];
    this[j] = temp;
  }

  /// Reverses the [List] in-place.
  void reverse() {
    var start = 0;
    var end = length - 1;
    while (start < end) {
      swap(start, end);

      start += 1;
      end -= 1;
    }
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

// ignore: public_member_api_docs
extension SortWithKeyExtension<E> on List<E> {
  /// Sorts [items] according to the computed sort key.
  ///
  /// This can be much more time-efficient (at the expense of space) than using
  /// [sort] with a custom comparison callback if comparisons are expensive.
  ///
  /// `K` intentionally extends from `Comparable<Object>` and not from
  /// `Comparable<K>` so that this works with `int` and `double` types (which
  /// otherwise would not work because `int` and `double` implement
  /// `Comparable<num>`).
  void sortWithKey<K extends Comparable<Object>>(
    K Function(E) key,
  ) {
    final keyPairs = [
      for (var element in this) _SortableKeyPair(element, key(element)),
    ]..sort();

    assert(length == keyPairs.length);
    for (var i = 0; i < length; i += 1) {
      this[i] = keyPairs[i].original;
    }
  }
}
