import 'dart:collection';
import 'dart:math' as math;

import 'package:dartbag/random.dart';
import 'package:test/test.dart';

class TrackedRandom implements math.Random {
  final _rawRandom = math.Random(0);
  int callCount = 0;

  @override
  bool nextBool() {
    callCount += 1;
    return _rawRandom.nextBool();
  }

  @override
  int nextInt(int max) {
    callCount += 1;
    return _rawRandom.nextInt(max);
  }

  @override
  double nextDouble() {
    callCount += 1;
    return _rawRandom.nextDouble();
  }
}

class FakeRandom implements math.Random {
  static final _instance = FakeRandom._();

  static int? currentSeed;

  factory FakeRandom([int? seed]) {
    currentSeed = seed;
    return _instance;
  }

  FakeRandom._();

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 9;

  @override
  double nextDouble() => 9;
}

void main() {
  test('Random.nextIntFrom works', () {
    var random = math.Random(0);
    for (var i = 0; i < 10; i += 1) {
      expect(random.nextIntFrom(5, 6), 5);
    }

    var results = [
      for (var i = 0; i < 100; i += 1) random.nextIntFrom(5, 10),
    ]..sort();

    expect(results[0], 5);
    expect(results[results.length - 1], 9);
  });

  group('lazyShuffler:', () {
    final original = UnmodifiableListView([for (var i = 0; i < 100; i += 1) i]);

    test('shuffles', () {
      var list = [...original];
      for (var _ in lazyShuffler(list, random: math.Random(0))) {}

      expect(list, isNot(original));
      expect(list..sort(), original);
    });

    test('is repeatable', () {
      var shuffled1 = [
        for (var i in lazyShuffler([...original], random: math.Random(0))) i,
      ];
      var shuffled2 = [
        for (var i in lazyShuffler([...original], random: math.Random(0))) i,
      ];

      expect(shuffled1, shuffled2);
      expect(shuffled1, isNot(same(shuffled2)));
    });

    test('shuffles lazily', () {
      var trackedRandom = TrackedRandom();

      var fullyShuffled = [
        for (var i in lazyShuffler([...original], random: trackedRandom)) i,
      ];

      var fullCallCount = trackedRandom.callCount;
      expect(fullCallCount, original.length);

      trackedRandom = TrackedRandom();
      var partiallyShuffled = [...original];

      var iterator =
          lazyShuffler(partiallyShuffled, random: trackedRandom).iterator;

      var n = 10;
      for (var i = 0; i < n; i += 1) {
        expect(iterator.moveNext(), true, reason: 'Iteration: $i');
        expect(iterator.current, partiallyShuffled[i], reason: 'Iteration: $i');
      }

      var lazyCallCount = trackedRandom.callCount;

      expect(lazyCallCount, n);

      expect(partiallyShuffled.getRange(0, n), fullyShuffled.getRange(0, n));
      expect(
        partiallyShuffled.getRange(n, partiallyShuffled.length),
        isNot(fullyShuffled.getRange(n, fullyShuffled.length)),
      );

      expect(partiallyShuffled, isNot(original));
      expect(partiallyShuffled..sort(), original);
    });
  });

  group('RepeatableRandom:', () {
    test('is repeatable', () {
      var random = RepeatableRandom();

      List<int> randomIntSequence() =>
          [for (var i = 0; i < 1000; i += 1) random.nextInt(100)];

      List<bool> randomBoolSequence() =>
          [for (var i = 0; i < 1000; i += 1) random.nextBool()];

      List<double> randomDoubleSequence() =>
          [for (var i = 0; i < 1000; i += 1) random.nextDouble()];

      var intSequence1 = randomIntSequence();
      var boolSequence1 = randomBoolSequence();
      var doubleSequence1 = randomDoubleSequence();

      random.restart();
      var intSequence2 = randomIntSequence();
      var boolSequence2 = randomBoolSequence();
      var doubleSequence2 = randomDoubleSequence();
      expect(intSequence1, intSequence2);
      expect(boolSequence1, boolSequence2);
      expect(doubleSequence1, doubleSequence2);

      // ignore: no_self_assignments, self-assignment for side-effect.
      random.seed = random.seed;
      intSequence2 = randomIntSequence();
      expect(intSequence1, intSequence2);
      expect(boolSequence1, boolSequence2);
      expect(doubleSequence1, doubleSequence2);
    });

    test('can use a different PRNG', () {
      var random = RepeatableRandom(FakeRandom.new);
      expect(random.nextInt(0), 9);
      expect(FakeRandom.currentSeed, random.seed);
    });
  });
}
