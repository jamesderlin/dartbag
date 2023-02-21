import 'package:dartbag/collection.dart';
import 'package:dartbag/comparable.dart';
import 'package:test/test.dart';

void main() {
  test('clamp', () {
    expect(5.clamp(0, 10), 5);
    expect(0.clamp(0, 10), 0);
    expect((-1).clamp(0, 10), 0);
    expect(10.clamp(0, 10), 10);
    expect(11.clamp(0, 10), 10);
  });

  test('compareIterables', () {
    const testCases = [
      _ComparisonTest(<int>[], <int>[], 0),
      _ComparisonTest(<int>[], [0], -1),
      _ComparisonTest([0], [0], 0),
      _ComparisonTest([0], [1], -1),
      _ComparisonTest([0], [0, 1], -1),
      _ComparisonTest([0, 1], [1], -1),
      _ComparisonTest([0, 1], [0, 1], 0),
      _ComparisonTest([0, 1], [1, 2], -1),
      _ComparisonTest([0, 0, 2], [0, 1, 2], -1),
      _ComparisonTest([0, 1, 1], [0, 1, 2], -1),
      _ComparisonTest(
        <Comparable<Object>>['Doe', 'John', 0],
        <Comparable<Object>>['Doe', 'John', 0],
        0,
      ),
      _ComparisonTest(
        <Comparable<Object>>['Doe', 'John', 0],
        <Comparable<Object>>['Doe', 'John', 1],
        -1,
      ),
      _ComparisonTest(
        <Comparable<Object>>['Doe', 'John', 0],
        <Comparable<Object>>['Doe', 'Jane', 0],
        1,
      ),
    ];

    for (var testCase in testCases) {
      if (testCase.expectedResult == 0) {
        expect(
          compareIterables(testCase.argument1, testCase.argument2),
          0,
          reason:
              'compareIterables(${testCase.argument1}, ${testCase.argument2})',
        );
        continue;
      }

      Matcher normalMatcher;
      Matcher reverseMatcher;

      if (testCase.expectedResult < 0) {
        normalMatcher = lessThan(0);
        reverseMatcher = greaterThan(0);
      } else {
        normalMatcher = greaterThan(0);
        reverseMatcher = lessThan(0);
      }

      expect(
        compareIterables(testCase.argument1, testCase.argument2),
        normalMatcher,
        reason:
            'compareIterables(${testCase.argument1}, ${testCase.argument2})',
      );

      expect(
        compareIterables(testCase.argument2, testCase.argument1),
        reverseMatcher,
        reason:
            'compareIterables(${testCase.argument2}, ${testCase.argument1})',
      );
    }
  });

  test('ComparableWrapper', () {
    var names = [
      const _Name('Smith', 'Jane'),
      const _Name('Doe', 'John'),
      const _Name('Doe', 'Jane'),
      const _Name('Galt', 'John'),
    ]..sortWithKey(
        (name) => ComparableWrapper(
          [name.surname, name.givenName],
          compareIterables,
        ),
      );

    expect(names, [
      const _Name('Doe', 'Jane'),
      const _Name('Doe', 'John'),
      const _Name('Galt', 'John'),
      const _Name('Smith', 'Jane'),
    ]);
  });
}

class _Name {
  final String surname;
  final String givenName;

  const _Name(this.surname, this.givenName);

  @override
  String toString() => '$givenName $surname';
}

class _ComparisonTest<Argument1Type, Argument2Type> {
  final Argument1Type argument1;
  final Argument2Type argument2;
  final int expectedResult;

  const _ComparisonTest(
    this.argument1,
    this.argument2,
    this.expectedResult,
  );
}
