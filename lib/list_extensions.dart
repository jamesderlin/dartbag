// ignore: public_member_api_docs
extension ReverseList<T> on List<T> {
  /// Reverses a [List] in-place.
  void reverse() {
    var start = 0;
    var end = length - 1;
    while (start < end) {
      var temp = this[start];
      this[start] = this[end];
      this[end] = temp;

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
  /// This can be much more efficient than using [sort] with a custom comparison
  /// callback if comparisons are expensive.
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
