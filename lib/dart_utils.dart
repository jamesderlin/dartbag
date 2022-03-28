import 'dart:typed_data';

/// Attempts to cast [object] to [T], returning `null` on failure.
///
/// This is a workaround until `as?` is implemented:
/// <https://github.com/dart-lang/language/issues/399>
T? tryCast<T>(Object? object) => object is T ? object : null;

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
extension AsUint8List on List<int> {
  /// Converts a `List<int>` to a [Uint8List].
  ///
  /// Attempts to cast to a [Uint8List] first to avoid creating an unnecessary
  /// copy.
  Uint8List asUint8List() {
    final self = this;
    return (self is Uint8List) ? self : Uint8List.fromList(this);
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

/// Returns a [Duration] as a human-readable string.
///
/// Example outputs:
/// 1d2h34m56.789s
/// 1d
/// 1d58s
/// 1d0.2s
String readableDuration(Duration duration) {
  if (duration.inMicroseconds == 0) {
    return '0s';
  }

  var sign = '';
  if (duration.isNegative) {
    sign = '-';
    duration = -duration;
  }

  var days = duration.inDays;
  var hours = duration.inHours % Duration.hoursPerDay;
  var minutes = duration.inMinutes % Duration.minutesPerHour;
  var seconds = duration.inSeconds % Duration.secondsPerMinute;
  var microseconds = duration.inMicroseconds % Duration.microsecondsPerSecond;

  var secondsString = '';
  if (microseconds > 0) {
    var fractionalSecondsString =
        '$microseconds'.padLeft(6, '0').replaceAll(RegExp(r'0+$'), '');
    secondsString = '$seconds.${fractionalSecondsString}s';
  } else if (seconds > 0) {
    secondsString = '${seconds}s';
  }

  var components = <String>[
    sign,
    if (days > 0) '${days}d',
    if (hours > 0) '${hours}h',
    if (minutes > 0) '${minutes}m',
    secondsString,
  ];

  return components.join();
}

// ignore: public_member_api_docs
extension ReadableDuration on Duration {
  /// An extension version of [readableDuration].
  String toReadableString() => readableDuration(this);
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
