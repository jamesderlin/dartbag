import 'package:dartbag/parse.dart';
import 'package:test/test.dart';

enum Color { red, green, blue }

void main() {
  test('tryParseInt/tryParseDouble', () {
    expect(tryParseInt(null), null);
    expect(tryParseInt('123'), 123);
    expect(tryParseDouble(null), null);
    expect(tryParseDouble('1.23'), 1.23);
  });

  group('tryParseBool:', () {
    test('Normal operations work', () {
      expect(tryParseBool('true'), true);
      expect(tryParseBool('yes'), true);
      expect(tryParseBool('1'), true);
      expect(tryParseBool('false'), false);
      expect(tryParseBool('no'), false);
      expect(tryParseBool('0'), false);

      expect(tryParseBool(null), null);
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
      expect(Color.values.tryParse(null), null);
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

  group('tryParseDuration', () {
    void runTestCases(Iterable<_DurationTestCase> testCases) {
      for (var testCase in testCases) {
        expect(
          tryParseDuration(testCase.normalDurationString),
          testCase.expectedDuration,
        );

        expect(
          tryParseDuration(testCase.readableDurationString),
          testCase.expectedDuration,
        );
      }
    }

    test('0s', () {
      runTestCases([
        _DurationTestCase('0s', Duration.zero),
        _DurationTestCase('+0s', Duration.zero),
        _DurationTestCase('-0s', Duration.zero),
      ]);
    });

    test('1s', () {
      runTestCases([_DurationTestCase('1s', const Duration(seconds: 1))]);
      runTestCases([_DurationTestCase('+1s', const Duration(seconds: 1))]);
    });

    test('Subseconds', () {
      runTestCases([
        _DurationTestCase('0.1s', const Duration(milliseconds: 100)),
        _DurationTestCase('0.01s', const Duration(milliseconds: 10)),
        _DurationTestCase('0.001s', const Duration(milliseconds: 1)),
        _DurationTestCase('0.0001s', const Duration(microseconds: 100)),
        _DurationTestCase('0.00001s', const Duration(microseconds: 10)),
        _DurationTestCase('0.000001s', const Duration(microseconds: 1)),
      ]);
    });

    test('All components', () {
      runTestCases([
        _DurationTestCase(
          '1d2h3m4s',
          const Duration(days: 1, hours: 2, minutes: 3, seconds: 4),
        ),
        _DurationTestCase(
          '1D2H3M4S',
          const Duration(days: 1, hours: 2, minutes: 3, seconds: 4),
        ),
        _DurationTestCase(
          '+1d2h3m4s',
          const Duration(days: 1, hours: 2, minutes: 3, seconds: 4),
        ),
        _DurationTestCase(
          '1d2h3m4.5s',
          const Duration(
            days: 1,
            hours: 2,
            minutes: 3,
            seconds: 4,
            milliseconds: 500,
          ),
        ),
        _DurationTestCase(
          '1d2h34m56s',
          const Duration(days: 1, hours: 2, minutes: 34, seconds: 56),
        ),
      ]);
    });

    test('Missing components', () {
      expect(
        tryParseDuration('1d2h3m'),
        const Duration(days: 1, hours: 2, minutes: 3),
      );
      expect(
        tryParseDuration('1d2h4s'),
        const Duration(days: 1, hours: 2, seconds: 4),
      );
      expect(
        tryParseDuration('1d3m4s'),
        const Duration(days: 1, minutes: 3, seconds: 4),
      );
      expect(
        tryParseDuration('2h3m4s'),
        const Duration(hours: 2, minutes: 3, seconds: 4),
      );
      expect(
        tryParseDuration('1h0.5s'),
        const Duration(hours: 1, milliseconds: 500),
      );
    });

    test('Whitespace-insensitive', () {
      const expectedDuration = Duration(
        days: 1,
        hours: 2,
        minutes: 3,
        seconds: 4,
      );
      expect(
        tryParseDuration('  1d2h3m4s  '),
        expectedDuration,
      );
      expect(
        tryParseDuration('  $expectedDuration  '),
        expectedDuration,
      );
    });

    test('Out-of-range values are handled', () {
      const expectedDuration = Duration(days: 2, hours: 1, minutes: 1);
      expect(
        tryParseDuration('1d24h60m60s'),
        expectedDuration,
      );
      expect(
        tryParseDuration('48:60:60.000000'),
        expectedDuration,
      );
    });

    test('Negative values', () {
      const duration = Duration(
        days: 1,
        hours: 2,
        minutes: 3,
        seconds: 4,
        milliseconds: 567,
        microseconds: 890,
      );

      runTestCases([
        _DurationTestCase('-1d2h3m4.56789s', -duration),
        _DurationTestCase('-0.5s', -const Duration(milliseconds: 500)),
      ]);
    });

    test('Excessive precision is rounded', () {
      expect(
        tryParseDuration('1d2h3m4.1234564s'),
        const Duration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          microseconds: 123456,
        ),
      );

      expect(
        tryParseDuration('1d2h3m4.1234567s'),
        const Duration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          microseconds: 123457,
        ),
      );

      expect(
        tryParseDuration('1d2h3m4.123456123456s'),
        const Duration(
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          microseconds: 123456,
        ),
      );
    });

    test('Fails to parse malformed strings', () {
      expect(tryParseDuration(null), null);
      expect(tryParseDuration(''), null);
      expect(tryParseDuration('  '), null);
      expect(tryParseDuration('0'), null);
      expect(tryParseDuration('0.0'), null);
      expect(tryParseDuration('1.2h'), null);
      expect(tryParseDuration('00:00'), null);
      expect(tryParseDuration('ms'), null);
      expect(tryParseDuration('2s1h'), null);
    });
  });
}

class _DurationTestCase {
  final String readableDurationString;
  final Duration expectedDuration;

  String get normalDurationString => '$expectedDuration';

  _DurationTestCase(this.readableDurationString, this.expectedDuration);
}
