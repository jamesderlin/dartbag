import 'dart:collection';
import 'dart:math' as math;

import 'package:dart_utils/dart_utils.dart';
import 'package:test/test.dart';

class TrackedRandom implements math.Random {
  TrackedRandom();

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

      // ignore: no_leading_underscores_for_local_identifiers
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
}
