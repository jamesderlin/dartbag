import 'dart:collection';
import 'dart:math';

import 'package:dart_utils/dart_utils.dart';
import 'package:test/test.dart';

void main() {
  test('staticType works', () {
    var someInt = 0;
    var someString = '';
    expect(someInt.staticType, int);
    expect(someString.staticType, String);

    num someNum = someInt;
    expect(someNum.runtimeType, int);
    expect(someNum.staticType, num);
  });

  test('tryCast works', () {
    num x = 7;
    expect(tryCast<int>(null), null);
    expect(tryCast<String>(x), null);
    expect(tryCast<int>(x), 7);
  });

  group('readableDuration:', () {
    test('0s', () {
      expect(Duration.zero.toReadableString(), '0s');
    });

    test('1s', () {
      expect(const Duration(seconds: 1).toReadableString(), '1s');
    });

    test('Subseconds', () {
      expect(const Duration(milliseconds: 100).toReadableString(), '0.1s');
      expect(const Duration(milliseconds: 10).toReadableString(), '0.01s');
      expect(const Duration(milliseconds: 1).toReadableString(), '0.001s');
      expect(const Duration(microseconds: 100).toReadableString(), '0.0001s');
      expect(const Duration(microseconds: 10).toReadableString(), '0.00001s');
      expect(const Duration(microseconds: 1).toReadableString(), '0.000001s');
    });

    test('All components', () {
      expect(
        const Duration(days: 1, hours: 2, minutes: 3, seconds: 4)
            .toReadableString(),
        '1d2h3m4s',
      );
      expect(
        const Duration(days: 1, hours: 2, minutes: 34, seconds: 56)
            .toReadableString(),
        '1d2h34m56s',
      );
    });

    test('Missing components', () {
      expect(
        const Duration(hours: 1, seconds: 2).toReadableString(),
        '1h2s',
      );
      expect(
        const Duration(hours: 1, milliseconds: 500).toReadableString(),
        '1h0.5s',
      );
    });
  });

  test('padDigits works', () {
    expect(0.padDigits(0), '0');
    expect(1.padDigits(0), '1');
    expect(0.padDigits(1), '0');
    expect(1.padDigits(1), '1');
    expect(0.padDigits(2), '00');
    expect(1.padDigits(2), '01');
    expect(100.padDigits(2), '100');
  });

  group('flattenDeep:', () {
    test('Empty list', () {
      expect(flattenDeep<int>(<int>[]), <int>[]);
    });

    test('No nested lists', () {
      expect(flattenDeep<int>([1, 2, 3]), [1, 2, 3]);
    });

    test('One level of nesting', () {
      expect(
        flattenDeep<int>([
          [1],
          [2],
          [3]
        ]),
        [1, 2, 3],
      );
    });

    test('Mixed types of iterables', () {
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
              [2]
            ]
          ],
          [
            3,
            [4, 5],
          ],
          6
        ]),
        [1, 2, 3, 4, 5, 6],
      );
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

      int trackedParse(String string) {
        trackedParseCallCount += 1;
        return int.parse(string);
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
}
