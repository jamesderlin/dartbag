import 'dart:math' as math;

import 'package:collection/collection.dart';

/// The maximum value allowed for [Random.nextInt].
// See <https://github.com/dart-lang/sdk/issues/48647>
const randMaxInt = (1 << 31) * 2;

/// Miscellaneous utility methods for [math.Random].
extension RandomUtils on math.Random {
  /// Returns a random intenger in the range \[`low`, `high`).
  int nextIntFrom(int low, int high) => low + nextInt(high - low);
}

/// Shuffles a [List] lazily.
///
/// Examples:
/// ```dart
/// var list = [for (var i = 0; i < 1000; i += 1) i];
///
/// // Draw 5 random elements from `list`.  The rest of `list` will contain the
/// // remaining elements in an indeterminate order.
/// var iterator = lazyShuffler(list).iterator;
/// for (var i = 0; i < 5 && iterator.moveNext(); i += 1) {
///   print(iterator.current);
/// }
///
/// // Alternatively, if resuming iteration later is unnecessary:
/// var i = 0;
/// for (var element in lazyShuffler(list)) {
///   if (i == 5) {
///     break;
///   }
///   print(element);
/// }
///
/// // Or:
/// lazyShuffler(list).take(5).forEach(print);
/// ```
/// Since advancing the iterator mutates `list`, `list[i]` in the example
/// above would have the same value as `iterator.current`.
Iterable<T> lazyShuffler<T>(List<T> list, {math.Random? random}) sync* {
  random ??= math.Random();
  for (var nextIndex = 0; nextIndex < list.length; nextIndex += 1) {
    var i = random.nextIntFrom(nextIndex, list.length);
    list.swap(nextIndex, i);
    yield list[nextIndex];
  }
}

/// A pseudo-random number generator that allows retrieving the existing seed
/// and that allows the random sequence to be easily restarted.
class RepeatableRandom implements math.Random {
  /// A random number generator that is *not* intended to be repeatable.
  ///
  /// Used to generate random seed values for a [RepeatableRandom] instance.
  static final _nonrepeatableRandom = math.Random();

  /// Returns a new seed value.
  static int newSeed() => _nonrepeatableRandom.nextInt(randMaxInt);

  /// The current seed value.
  ///
  /// Automatically generated lazily if a seed value has not been manually set.
  late int _seed = newSeed();

  /// Gets the current seed value.
  int get seed => _seed;

  /// Sets a new seed value and restarts the random sequence.
  ///
  /// Note that setting to the current seed value is *not* a no-op and instead
  /// will restart the current sequence.
  set seed(int value) {
    // We intentionally create a new [math.Random] object even if the seed value
    // hasn't changed.  This ensures that we always produce the same sequence of
    // random numbers after setting the seed regardless of the previous history.
    _seed = value;
    restart();
  }

  /// The underlying pseudo-random number generator.
  late math.Random _random = math.Random(_seed);

  /// Restarts the current random sequence.
  void restart() => _random = math.Random(_seed);

  @override
  bool nextBool() => _random.nextBool();

  @override
  double nextDouble() => _random.nextDouble();

  @override
  int nextInt(int max) => _random.nextInt(max);
}
