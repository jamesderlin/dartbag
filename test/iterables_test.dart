import 'dart:collection';
import 'dart:math';

import 'package:dartbag/iterables.dart';
import 'package:test/test.dart';

extension<E> on List<E> {
  void rotateLeftSlow(
    int shiftAmount, {
    int? start,
    int? end,
  }) {
    for (var i = 0; i < shiftAmount; i += 1) {
      rotateLeft(1, start: start, end: end);
    }
  }
}

void main() {
  group('rotateLeft:', () {
    const oddList = [0, 1, 2, 3, 4, 5, 6];
    const evenList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    assert(oddList.length.isOdd);
    assert(evenList.length.isEven);

    test('Empty list', () {
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

      var stopwatch = Stopwatch()..start();
      for (var list in [oddList, evenList]) {
        for (var i = 0; i < list.length; i += 1) {
          expect(
            [...list]..rotateLeft(i),
            [...list]..rotateLeftSlow(i),
            reason: 'shiftAmount: $i',
          );
        }
      }
      print(stopwatch.elapsed);
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
            [...list]..rotateLeft(list.length - i),
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

  group('sortWithKey:', () {
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
        'List.sort() duration:        $regularDuration\n'
        'List.sortWithKey() duration: $keyDuration\n'
        'Speedup: ${speedup.toStringAsFixed(1)}x',
      );
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
}
