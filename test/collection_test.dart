import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:dartbag/collection.dart';
import 'package:dartbag/readable_numbers.dart';
import 'package:test/test.dart';

extension<E> on List<E> {
  List<E> rotateLeftCopy(
    int shiftAmount, {
    int? start,
    int? end,
  }) {
    var copy = toList();

    start ??= 0;
    end ??= length;

    var rotatedLength = end - start;
    for (var i = 0; i < rotatedLength; i += 1) {
      copy[i + start] = this[(i + shiftAmount) % rotatedLength + start];
    }

    return copy;
  }
}

void main() {
  group('flattenDeep:', () {
    test('Empty List', () {
      expect(flattenDeep<int>(<int>[]), <int>[]);
    });

    test('No nested Lists', () {
      expect(flattenDeep<int>([1, 2, 3]), [1, 2, 3]);
    });

    test('One level of nesting', () {
      expect(
        flattenDeep<int>([
          [1],
          [2],
          [3],
        ]),
        [1, 2, 3],
      );
    });

    test('Mixed types of Iterables', () {
      expect(
        flattenDeep<int>([
          [1],
          {2},
          [3].map((x) => x),
        ]),
        [1, 2, 3],
      );
    });

    test('Multiple levels of nesting', () {
      expect(
        flattenDeep<int>([
          [
            [1],
            [
              [2],
            ],
          ],
          [
            3,
            [4, 5],
          ],
          6,
        ]),
        [1, 2, 3, 4, 5, 6],
      );
    });
  });

  group('List.rotateLeft:', () {
    const oddList = [0, 1, 2, 3, 4, 5, 6];
    const evenList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    assert(oddList.length.isOdd);
    assert(evenList.length.isEven);

    test('Empty List', () {
      expect(<int>[]..rotateLeft(0), <int>[]);
      expect(<int>[]..rotateLeft(1), <int>[]);
      expect(<int>[]..rotateLeft(-1), <int>[]);
    });

    test('shiftAmount == 0', () {
      for (var list in [oddList, evenList]) {
        expect([...list]..rotateLeft(0), list);
      }
    });

    test('shiftAmount > 0', () {
      expect(
        [...oddList]..rotateLeft(1),
        [1, 2, 3, 4, 5, 6, 0],
      );
      expect(
        [...evenList]..rotateLeft(1),
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0],
      );

      for (var list in [oddList, evenList]) {
        for (var i = 0; i < list.length; i += 1) {
          expect(
            [...list]..rotateLeft(i),
            [...list].rotateLeftCopy(i),
            reason: 'shiftAmount: $i',
          );
        }
      }
    });

    test('shiftAmount < 0', () {
      expect(
        [...oddList]..rotateLeft(-1),
        [6, 0, 1, 2, 3, 4, 5],
      );
      expect(
        [...evenList]..rotateLeft(-1),
        [11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      for (var list in [oddList, evenList]) {
        for (var i = 0; i < list.length; i += 1) {
          expect(
            [...list]..rotateLeft(-i),
            [...list].rotateLeftCopy(-i),
            reason: 'shiftAmount: -$i',
          );
        }
      }
    });

    test('shiftAmount >= length', () {
      for (var list in [oddList, evenList]) {
        expect([...list]..rotateLeft(list.length), list);
        expect(
          [...list]..rotateLeft(list.length + 1),
          [...list]..rotateLeft(1),
        );
        expect(
          [...list]..rotateLeft(list.length + 2),
          [...list]..rotateLeft(2),
        );
        expect(
          [...list]..rotateLeft(list.length * 2 + 1),
          [...list]..rotateLeft(1),
        );
      }
    });

    test('shiftAmount <= -length', () {
      for (var list in [oddList, evenList]) {
        expect([...list]..rotateLeft(-list.length), list);
        expect(
          [...list]..rotateLeft(-list.length - 1),
          [...list]..rotateLeft(-1),
        );
        expect(
          [...list]..rotateLeft(-list.length - 2),
          [...list]..rotateLeft(-2),
        );
        expect(
          [...list]..rotateLeft(-list.length * 2 + -1),
          [...list]..rotateLeft(-1),
        );
      }
    });

    test('ranges work', () {
      var preamble = <Object>['a', 'b', 'c'];
      var postamble = <Object>['w', 'x', 'y', 'z'];

      for (var i = 0; i < oddList.length; i += 1) {
        expect(
          (preamble + oddList + postamble)
            ..rotateLeft(
              i,
              start: preamble.length,
              end: preamble.length + oddList.length,
            ),
          preamble + ([...oddList]..rotateLeft(i)) + postamble,
          reason: 'shiftAmount: $i',
        );
      }
    });
  });

  group('List.sortWithKey:', () {
    final random = Random(0);
    final ordered =
        UnmodifiableListView([for (var i = 0; i < 1000; i += 1) '$i']);
    final shuffled = UnmodifiableListView(ordered.toList()..shuffle(random));

    test('Sorts correctly', () {
      expect(<String>[]..sortWithKey(int.parse), <String>[]);

      var shuffledCopy = shuffled.toList()..sortWithKey(int.parse);
      expect(shuffledCopy, ordered);
    });

    test('Sorts efficiently', () {
      var trackedParseCallCount = 0;

      BigInt trackedParse(String string) {
        trackedParseCallCount += 1;

        // [BigInt] is significantly more expensive than native [int].
        return BigInt.parse(string);
      }

      var stopwatch = Stopwatch()..start();
      shuffled.toList().sort((a, b) {
        var valueA = trackedParse(a);
        var valueB = trackedParse(b);
        return valueA.compareTo(valueB);
      });
      var regularDuration = stopwatch.elapsed;

      var regularCallCount = trackedParseCallCount;
      trackedParseCallCount = 0;

      stopwatch
        ..reset()
        ..start();
      shuffled.toList().sortWithKey(trackedParse);
      var keyDuration = stopwatch.elapsed;

      var keyCallCount = trackedParseCallCount;

      expect(keyCallCount, lessThan(regularCallCount));
      expect(keyDuration, lessThan(regularDuration));

      var speedup = regularDuration.inMicroseconds / keyDuration.inMicroseconds;
      print(
        'List.sort() element conversion count:        $regularCallCount\n'
        'List.sortWithKey() element conversion count: $keyCallCount\n'
        'List.sort() duration:        ${regularDuration.toReadableString()}\n'
        'List.sortWithKey() duration: ${keyDuration.toReadableString()}\n'
        'Speedup: ${speedup.toStringAsFixed(1)}x',
      );
    });
  });

  group('List.sortWithAsyncKey', () {
    final random = Random(0);
    final ordered =
        UnmodifiableListView([for (var i = 0; i < 1000; i += 1) '$i']);
    final shuffled = UnmodifiableListView(ordered.toList()..shuffle(random));

    test('Sorts correctly', () async {
      Future<int> parseAsync(String string) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return int.parse(string);
      }

      var emptyList = <String>[];
      await emptyList.sortWithAsyncKey(parseAsync);
      expect(emptyList, <String>[]);

      var shuffledCopy = shuffled.toList();
      await shuffledCopy.sortWithAsyncKey(parseAsync);

      expect(shuffledCopy, ordered);
    });
  });

  test('Iterable.drain', () {
    var list = [1, 2, 3];
    var result = 0;
    var iterable = list.map((x) => result = result * result + x);
    expect(result, 0);
    iterable.drain();
    expect(result, 12);
  });

  group('Iterable.startsWith:', () {
    test('empty Lists', () {
      expect(<int>[].startsWith(<int>[]), true);
      expect(<int>[].startsWith([1]), false);
      expect([1].startsWith(<int>[]), true);
    });

    test('Works normally', () {
      expect([1, 2, 3].startsWith([1]), true);
      expect([1, 2, 3].startsWith([1, 2]), true);
      expect([1, 2, 3].startsWith([1, 2, 3]), true);
      expect([1, 2, 3].startsWith([1, 2, 3, 4]), false);
      expect([1, 2, 3].startsWith([0]), false);
      expect([1, 2, 3].startsWith([2]), false);
      expect([1, 2, 3].startsWith([3]), false);
      expect([1, 2, 3].startsWith([1, 1]), false);
      expect([1, 2, 3].startsWith([0, 1]), false);
    });
  });

  test('Iterable.padLeft:', () {
    const padValue = -48;

    expect(<int>[].padLeft(0, padValue: padValue).toList(), <int>[]);
    expect(<int>[].padLeft(1, padValue: padValue).toList(), [padValue]);
    expect(
      <int>[].padLeft(2, padValue: padValue).toList(),
      [padValue, padValue],
    );
    expect(<int>[].padLeft(2, padValue: padValue).length, 2);
    expect([0].padLeft(0, padValue: padValue).toList(), [0]);
    expect([0].padLeft(1, padValue: padValue).toList(), [0]);
    expect([0].padLeft(2, padValue: padValue).toList(), [padValue, 0]);
    expect(
      [0].padLeft(3, padValue: padValue).toList(),
      [padValue, padValue, 0],
    );
    expect([0, 1].padLeft(0, padValue: padValue).toList(), [0, 1]);
    expect([0, 1].padLeft(1, padValue: padValue).toList(), [0, 1]);
    expect([0, 1].padLeft(2, padValue: padValue).toList(), [0, 1]);
    expect([0, 1].padLeft(3, padValue: padValue).toList(), [padValue, 0, 1]);
    expect([0, 1].padLeft(3, padValue: padValue).length, 3);
  });

  test('Iterable.padRight:', () {
    const padValue = -48;

    expect(<int>[].padRight(0, padValue: 0).toList(), <int>[]);
    expect(<int>[].padRight(1, padValue: padValue).toList(), [padValue]);
    expect(
      <int>[].padRight(2, padValue: padValue).toList(),
      [padValue, padValue],
    );
    expect(<int>[].padRight(2, padValue: padValue).length, 2);
    expect([0].padRight(0, padValue: padValue).toList(), [0]);
    expect([0].padRight(1, padValue: padValue).toList(), [0]);
    expect([0].padRight(2, padValue: padValue).toList(), [0, padValue]);
    expect(
      [0].padRight(3, padValue: padValue).toList(),
      [0, padValue, padValue],
    );
    expect([0, 1].padRight(0, padValue: padValue).toList(), [0, 1]);
    expect([0, 1].padRight(1, padValue: padValue).toList(), [0, 1]);
    expect([0, 1].padRight(2, padValue: padValue).toList(), [0, 1]);
    expect([0, 1].padRight(3, padValue: padValue).toList(), [0, 1, padValue]);
    expect([0, 1].padRight(3, padValue: padValue).length, 3);
  });

  group('zipLongest', () {
    const padValue = -48;

    test('Works with finite iterables', () {
      expect(zipLongest([<int>[]], padValue).toList(), <List<int>>[]);
      expect(
          zipLongest(
            [
              <int>[],
              [1],
            ],
            padValue,
          ).toList(),
          [
            [padValue, 1],
          ]);
      expect(
          zipLongest(
            [
              [1],
              <int>[],
            ],
            padValue,
          ).toList(),
          [
            [1, padValue],
          ]);
      expect(
          zipLongest(
            [
              <int>[],
              [1],
              <int>[],
            ],
            padValue,
          ).toList(),
          [
            [padValue, 1, padValue],
          ]);

      expect(
          zipLongest(
            [
              [1, 2, 3],
            ],
            padValue,
          ).toList(),
          [
            [1],
            [2],
            [3],
          ]);
      expect(
          zipLongest(
            [
              <int>[],
              [1, 2, 3],
            ],
            padValue,
          ).toList(),
          [
            [padValue, 1],
            [padValue, 2],
            [padValue, 3],
          ]);
      expect(
          zipLongest(
            [
              [1, 2, 3],
              <int>[],
            ],
            padValue,
          ).toList(),
          [
            [1, padValue],
            [2, padValue],
            [3, padValue],
          ]);

      expect(
          zipLongest(
            [
              [1, 2, 3],
              [4, 5],
              [6],
            ],
            padValue,
          ).toList(),
          [
            [1, 4, 6],
            [2, 5, padValue],
            [3, padValue, padValue],
          ]);
    });

    test('Works with infinite iterables', () {
      expect(
        zipLongest(
          [
            _naturalNumbers,
          ],
          padValue,
        ).take(5).toList(),
        [
          [1],
          [2],
          [3],
          [4],
          [5],
        ],
      );

      expect(
        zipLongest(
          [
            _naturalNumbers,
            <int>[],
          ],
          padValue,
        ).take(5).toList(),
        [
          [1, padValue],
          [2, padValue],
          [3, padValue],
          [4, padValue],
          [5, padValue],
        ],
      );

      expect(
        zipLongest(
          [
            <int>[],
            _naturalNumbers,
          ],
          padValue,
        ).take(5).toList(),
        [
          [padValue, 1],
          [padValue, 2],
          [padValue, 3],
          [padValue, 4],
          [padValue, 5],
        ],
      );

      expect(
        zipLongest(
          [
            [-1, -2, -3],
            _naturalNumbers,
          ],
          padValue,
        ).take(5).toList(),
        [
          [-1, 1],
          [-2, 2],
          [-3, 3],
          [padValue, 4],
          [padValue, 5],
        ],
      );
    });
  });

  test('LinkedHashMap.sort', () {
    final random = Random(0);

    final asciiLittleA = 'a'.codeUnits[0];
    var keys = [
      for (var i = 0; i < 26; i += 1) String.fromCharCode(i + asciiLittleA),
    ];
    var values = [for (var i = 0; i < keys.length; i += 1) i];

    keys.shuffle(random);
    values.shuffle(random);

    var map = LinkedHashMap.fromIterables(keys, values);
    var mapCopy = {...map};

    assert(!_isSorted(map.keys));
    assert(!_isSorted(map.values));

    map.sort((entry1, entry2) => entry1.key.compareTo(entry2.key));
    expect(map.keys, map.keys.toList()..sort());
    expect(_isSorted(map.values), false);
    expect(map, mapCopy);

    map.sort((entry1, entry2) => entry1.value.compareTo(entry2.value));
    expect(map.values, map.values.toList()..sort());
    expect(_isSorted(map.keys), false);
    expect(map, mapCopy);
  });

  group('mergeMaps:', () {
    const emptyMap = <String, int>{};

    test('Empty List', () {
      expect(mergeMaps(<Map<String, int>>[]), emptyMap);
    });

    test('List with empty Maps', () {
      expect(mergeMaps([emptyMap, emptyMap]), emptyMap);
    });

    test('List with a single Map', () {
      var map = {'a': 1, 'b': 2, 'c': 3};
      expect(
        mergeMaps([map]),
        map.map((key, value) => MapEntry(key, [value])),
      );
    });

    test('List with multiple Maps', () {
      var merged = mergeMaps([
        {'a': 1, 'b': 2},
        {'a': 10, 'b': 20, 'c': 30},
        {'a': 100},
      ]);

      expect(merged, {
        'a': [1, 10, 100],
        'b': [2, 20],
        'c': [30],
      });

      var foldedValues = {
        for (var entry in merged.entries)
          entry.key: entry.value.fold(0, (a, b) => a + b),
      };
      expect(foldedValues, {'a': 111, 'b': 22, 'c': 30});

      var earliestValues = {
        for (var entry in merged.entries) entry.key: entry.value.first,
      };
      expect(earliestValues, {'a': 1, 'b': 2, 'c': 30});
    });
  });

  group('FutureMap.wait:', () {
    Future<T> returnLater<T>(
      T value, [
      Duration duration = const Duration(milliseconds: 100),
    ]) async {
      await Future<void>.delayed(duration);
      return value;
    }

    Future<Never> failLater(Duration duration) async {
      await Future<void>.delayed(duration);
      throw Exception('Expected failure');
    }

    test('Waits for values in parallel', () async {
      var map = {
        'a': returnLater(1),
        'b': returnLater(2, const Duration(milliseconds: 500)),
        'c': returnLater(3),
        'd': returnLater(4, const Duration(milliseconds: 250)),
        'e': returnLater(5),
      };

      var stopwatch = Stopwatch()..start();
      var result = await map.wait;
      expect(stopwatch.elapsed.inMilliseconds, inClosedOpenRange(500, 1000));
      expect(result, {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5});
    });

    test('Ignores mutations to the original Map', () async {
      var map = {
        'a': returnLater(1),
        'b': returnLater(2, const Duration(milliseconds: 500)),
        'c': returnLater(3),
        'd': returnLater(4, const Duration(milliseconds: 250)),
        'e': returnLater(5),
      };

      var futureResult = map.wait;
      map.remove('a')?.ignore();
      map.remove('b')?.ignore();
      map['c'] = returnLater(99);

      var result = await futureResult;
      expect(result, {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5});
    });

    test('Failures are propagated', () async {
      var map = {
        'a': returnLater(1),
        'b': failLater(const Duration(milliseconds: 500)),
        'c': returnLater(3),
        'd': failLater(const Duration(milliseconds: 250)),
        'e': returnLater(null),
      };

      var stopwatch = Stopwatch()..start();

      try {
        var futureResult = map.wait;
        map.remove('a')?.ignore();
        map.remove('b')?.ignore();
        map['c'] = returnLater(99);

        await futureResult;
        fail('Failed to fail.');

        // ignore: avoid_catching_errors
      } on ParallelMapWaitError<String, int?> catch (e) {
        expect(stopwatch.elapsed.inMilliseconds, inClosedOpenRange(500, 1000));
        expect(e.values, {'a': 1, 'c': 3, 'e': null});
        expect(e.errors.keys.toSet(), {'b', 'd'});
      }
    });
  });
}

/// Returns `true` if [iterable] is already sorted based on its natural
/// [Comparable] ordering, `false` otherwise.
bool _isSorted<E extends Comparable<Object>>(Iterable<E> iterable) {
  var iterator = iterable.iterator;
  if (!iterator.moveNext()) {
    return true;
  }

  var previousValue = iterator.current;
  while (iterator.moveNext()) {
    var currentValue = iterator.current;
    if (previousValue.compareTo(currentValue) > 0) {
      return false;
    }
    previousValue = currentValue;
  }
  return true;
}

/// Returns an infinite [Iterable] of the natural numbers.
Iterable<int> get _naturalNumbers sync* {
  var i = 1;
  while (true) {
    yield i;
    i += 1;
  }
}
