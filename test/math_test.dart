import 'dart:math' as math;

import 'package:dartbag/math.dart';
import 'package:test/test.dart';

void main() {
  test('lcm', () {
    const testCases = [
      _BinaryOperatorTest(0, 0, expected: 0),
      _BinaryOperatorTest(0, 1, expected: 0),
      _BinaryOperatorTest(1, 1, expected: 1),
      _BinaryOperatorTest(1, 2, expected: 2),
      _BinaryOperatorTest(2, 3, expected: 6),
      _BinaryOperatorTest(2, 6, expected: 6),
      _BinaryOperatorTest(4, 6, expected: 12),
      _BinaryOperatorTest(0, -1, expected: 0),
      _BinaryOperatorTest(-2, 3, expected: 6),
      _BinaryOperatorTest(2, -3, expected: 6),
      _BinaryOperatorTest(-2, -3, expected: 6),
    ];

    for (var testCase in testCases) {
      expect(
        lcm(testCase.argument1, testCase.argument2),
        testCase.expectedResult,
        reason: 'lcm(${testCase.argument1}, ${testCase.argument2})',
      );

      if (testCase.argument1 != testCase.argument2) {
        expect(
          lcm(testCase.argument2, testCase.argument1),
          testCase.expectedResult,
          reason: 'lcm(${testCase.argument2}, ${testCase.argument1})',
        );
      }
    }
  });

  test('floorToMultipleOf', () {
    const expectedMultiplesOf5 = <int, int>{
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 5,
    };

    const expectedMultiplesOf10 = <int, int>{
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
      7: 0,
      8: 0,
      9: 0,
      10: 10,
    };

    int wrappedExtension(int value, int multiplier) =>
        value.floorToMultipleOf(multiplier);

    const extensionName = 'floorToMultipleOf';

    _testMultipleOf(wrappedExtension, extensionName, 5, expectedMultiplesOf5);
    _testMultipleOf(wrappedExtension, extensionName, 10, expectedMultiplesOf10);
  });

  test('ceilToMultipleOf', () {
    const expectedMultiplesOf5 = <int, int>{
      0: 0,
      1: 5,
      2: 5,
      3: 5,
      4: 5,
      5: 5,
    };

    const expectedMultiplesOf10 = <int, int>{
      0: 0,
      1: 10,
      2: 10,
      3: 10,
      4: 10,
      5: 10,
      6: 10,
      7: 10,
      8: 10,
      9: 10,
      10: 10,
    };

    int wrappedExtension(int value, int multiplier) =>
        value.ceilToMultipleOf(multiplier);

    const extensionName = 'ceilToMultipleOf';

    _testMultipleOf(wrappedExtension, extensionName, 5, expectedMultiplesOf5);
    _testMultipleOf(wrappedExtension, extensionName, 10, expectedMultiplesOf10);
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

    int wrappedExtension(int value, int multiplier) =>
        value.roundToMultipleOf(multiplier);

    const extensionName = 'roundToMultipleOf';

    _testMultipleOf(wrappedExtension, extensionName, 5, expectedMultiplesOf5);
    _testMultipleOf(wrappedExtension, extensionName, 10, expectedMultiplesOf10);
  });

  test('Rectangle.center', () {
    expect(
      const math.Rectangle<int>(0, 0, 200, 80).center,
      const math.Point<num>(100, 40),
    );

    expect(
      const math.Rectangle<int>(-20, -10, 200, 80).center,
      const math.Point<num>(80, 30),
    );

    expect(
      const math.Rectangle<int>(3, 2, 0, 0).center,
      const math.Point<num>(3, 2),
    );
  });
}

void _testMultipleOf(
  int Function(int value, int multiplier) function,
  String functionName,
  int multiplier,
  Map<int, int> expectedMultiples,
) {
  var random = math.Random(0);

  for (var entry in expectedMultiples.entries) {
    var n = entry.key;
    var expected = entry.value;
    expect(
      function(entry.key, multiplier),
      entry.value,
      reason: '$n.$functionName($multiplier) => $expected',
    );
  }

  for (var i = 0; i < 100; i += 1) {
    var exactMultiple = random.nextInt(1000) * multiplier;
    for (var i = 0; i < multiplier; i += 1) {
      var n = exactMultiple + i;
      var expected = exactMultiple + expectedMultiples[i]!;
      expect(
        function(n, multiplier),
        expected,
        reason: '$n.$functionName($multiplier) => $expected',
      );
    }
  }
}

class _BinaryOperatorTest<ArgumentType, ResultType> {
  final ArgumentType argument1;
  final ArgumentType argument2;

  final ResultType expectedResult;

  const _BinaryOperatorTest(
    this.argument1,
    this.argument2, {
    required ResultType expected,
  }) : expectedResult = expected;
}
