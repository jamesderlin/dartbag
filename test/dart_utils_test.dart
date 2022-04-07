import 'dart:math' as math;

import 'package:dart_utils/dart_utils.dart';
import 'package:test/test.dart';

enum Color { red, green, blue }

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

  test('tryAs works', () {
    num x = 7;
    expect(null.tryAs<int>(), null);
    expect(x.tryAs<String>(), null);
    expect(x.tryAs<int>(), 7);
  });

  test('OutputParameter<T> works', () {
    void f(OutputParameter<int> output) {
      output.value = 42;
    }

    var result = OutputParameter<int>(0);
    f(result);
    expect(result.value, 42);
  });

  test('int.padDigits works', () {
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

  group('tryParseBool:', () {
    test('Normal operations work', () {
      expect(tryParseBool('true'), true);
      expect(tryParseBool('yes'), true);
      expect(tryParseBool('1'), true);
      expect(tryParseBool('false'), false);
      expect(tryParseBool('no'), false);
      expect(tryParseBool('0'), false);

      expect(tryParseBool(''), null);
      expect(tryParseBool('2'), null);
      expect(tryParseBool('maybe'), null);
    });
    test('Case-insensitive', () {
      expect(tryParseBool('TRuE'), true);
      expect(tryParseBool('FaLSE'), false);
    });
    test('Whitespace-insensitive', () {
      expect(tryParseBool('  \ttrue\n  '), true);
      expect(tryParseBool('  \tno\n    '), false);

      expect(tryParseBool(' \t\n'), null);
    });
    test('Miscellaneous negative cases', () {
      expect(tryParseBool('1.0'), null);
      expect(tryParseBool('00'), null);
      expect(tryParseBool('yesman'), null);
      expect(tryParseBool('y'), null);
      expect(tryParseBool('n'), null);
    });
  });

  group('List<Enum>.tryParse:', () {
    test('Normal operations work', () {
      expect(Color.values.tryParse('red'), Color.red);
      expect(Color.values.tryParse('green'), Color.green);
      expect(Color.values.tryParse('blue'), Color.blue);
    });
    test('Returns null for unrecognized values', () {
      expect(Color.values.tryParse(''), null);
      expect(Color.values.tryParse('fuchsia'), null);
      expect(Color.values.tryParse('reddish'), null);
    });
    test('Case-sensitivity works', () {
      expect(Color.values.tryParse('Blue'), Color.blue);
      expect(Color.values.tryParse('Blue', caseSensitive: true), null);
    });
    test('Whitespace-insensitive', () {
      expect(Color.values.tryParse(' \tblue\n '), Color.blue);
      expect(Color.values.tryParse(' \tBlue\n '), Color.blue);
    });
  });

  test('Uri.updateQueryParameters', () {
    var uri = Uri.parse(
      'https://user@www.example.com:8080/'
      '?foo=bar&lorem=ipsum&nine=9#anchor',
    );
    expect(
      uri.updateQueryParameters({'lorem': 'dolor'}).toString(),
      'https://user@www.example.com:8080/?foo=bar&lorem=dolor&nine=9#anchor',
    );

    expect(
      uri.updateQueryParameters({'nine': '10'}).toString(),
      'https://user@www.example.com:8080/?foo=bar&lorem=ipsum&nine=10#anchor',
    );
    expect(
      uri.updateQueryParameters({'ten': '10'}).toString(),
      'https://user@www.example.com:8080/'
      '?foo=bar&lorem=ipsum&nine=9&ten=10#anchor',
    );
  });
  test('Rectangle.center', () {
    expect(
      const math.Rectangle(10, 20, 100, 200).center,
      const math.Point(60, 120),
    );
    expect(
      const math.Rectangle(-10, -20, 100, 200).center,
      const math.Point(40, 80),
    );

    expect(
      const math.Rectangle(10, 20, 0, 0).center,
      const math.Point(10, 20),
    );
  });

  test('roundToMultiple', () {
    const expectedMultiplesOf5 = <int, int>{
      0: 0,
      1: 0,
      2: 0,
      3: 5,
      4: 5,
      5: 5,
    };

    const expectedMultiplesOf10 = <int, int>{
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 10,
      6: 10,
      7: 10,
      8: 10,
      9: 10,
      10: 10,
    };

    var random = math.Random(0);
    void helper(int multiplier, Map<int, int> expectedMultiples) {
      for (var entry in expectedMultiples.entries) {
        var n = entry.key;
        var expected = entry.value;
        expect(
          entry.key.roundToMultipleOf(multiplier),
          entry.value,
          reason: '$n.roundToMultipleOf($multiplier) => $expected',
        );
      }

      for (var i = 0; i < 100; i += 1) {
        var exactMultiple = random.nextInt(1000) * multiplier;
        for (var i = 0; i < multiplier; i += 1) {
          var n = exactMultiple + i;
          var expected = exactMultiple + expectedMultiples[i]!;
          expect(
            n.roundToMultipleOf(multiplier),
            expected,
            reason: '$n.roundToMultipleOf($multiplier) => $expected',
          );
        }
      }
    }

    helper(5, expectedMultiplesOf5);
    helper(10, expectedMultiplesOf10);
  });
}
