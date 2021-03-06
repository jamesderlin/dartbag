import 'dart:math' as math;

import 'package:dartbag/iterables.dart';
import 'package:dartbag/misc.dart';
import 'package:test/test.dart';

void main() {
  test('tryAs', () {
    num x = 7;
    expect(null.tryAs<int>(), null);
    expect(x.tryAs<String>(), null);
    expect(x.tryAs<int>(), 7);
  });

  test('chainIf', () {
    var list = [1, 2, 3]..chainIf(true)?.reverse();
    expect(list, [3, 2, 1]);

    list = [1, 2, 3]..chainIf(false)?.reverse();
    expect(list, [1, 2, 3]);
  });

  test('OutputParameter<T>', () {
    void f(OutputParameter<int> output) {
      output.value = 42;
    }

    var result = OutputParameter<int>(0);
    f(result);
    expect(result.value, 42);
  });

  group('int.padDigits:', () {
    test('non-negative integers', () {
      expect(0.padDigits(0), '0');
      expect(1.padDigits(0), '1');
      expect(0.padDigits(1), '0');
      expect(1.padDigits(1), '1');
      expect(0.padDigits(2), '00');
      expect(1.padDigits(2), '01');
      expect(100.padDigits(2), '100');
    });

    test('negative integers', () {
      expect((-0).padDigits(0), '0');
      expect((-1).padDigits(0), '-1');
      expect((-0).padDigits(1), '0');
      expect((-1).padDigits(1), '-1');
      expect((-0).padDigits(2), '00');
      expect((-1).padDigits(2), '-1');
      expect((-0).padDigits(3), '000');
      expect((-1).padDigits(3), '-01');
    });
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

  test('int.roundToMultiple', () {
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

  test('bool.implies', () {
    expect(false.implies(false), true);
    expect(false.implies(true), true);
    expect(true.implies(false), false);
    expect(true.implies(true), true);
  });

  test('Future.cast', () async {
    expect(polymorphicFuture(), isA<Future<Derived>>());
    expect(polymorphicFuture(), isA<Future<Base>>());
    expect(polymorphicFuture().cast<Base>(), isA<Future<Base>>());
    expect(polymorphicFuture().cast<Base>(), isNot(isA<Future<Derived>>()));

    expect(
      () => polymorphicFuture()
          .timeout(const Duration(milliseconds: 1), onTimeout: Base.new),
      throwsA(isA<TypeError>()),
    );

    expect(
      () => polymorphicFuture()
          .cast<Base>()
          .timeout(const Duration(milliseconds: 1), onTimeout: Base.new),
      returnsNormally,
    );
  });
}

class Base {}

class Derived extends Base {}

/// Returns a [Future] that has a static type of `Future<Base>` but that has a
/// runtime type of `Future<Derived>`.
Future<Base> polymorphicFuture() =>
    Future<Derived>.delayed(const Duration(milliseconds: 10), Derived.new);
