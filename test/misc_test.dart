import 'package:collection/collection.dart';
import 'package:dartbag/collection.dart';
import 'package:dartbag/misc.dart';
import 'package:dartbag/parse.dart';
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

  test('isSubtype', () {
    expect(isSubtype<int, num>(), true);
    expect(isSubtype<num, int>(), false);
    expect(isSubtype<int, String>(), false);
    expect(isSubtype<int, void>(), true);
    expect(isSubtype<void, int>(), false);
    expect(isSubtype<Future<int>, Future<dynamic>>(), true);
    expect(isSubtype<Future<dynamic>, Future<int>>(), false);
  });

  test('OutputParameter<T>', () {
    void f(OutputParameter<int> output) {
      output.value = 42;
    }

    var result = OutputParameter<int>(0);
    f(result);
    expect(result.value, 42);
  });

  group('int.padLeft:', () {
    test('non-negative integers', () {
      expect(0.padLeft(0), '0');
      expect(1.padLeft(0), '1');
      expect(0.padLeft(1), '0');
      expect(1.padLeft(1), '1');
      expect(0.padLeft(2), '00');
      expect(1.padLeft(2), '01');
      expect(100.padLeft(2), '100');
    });

    test('negative integers', () {
      expect((-0).padLeft(0), '0');
      expect((-1).padLeft(0), '-1');
      expect((-0).padLeft(1), '0');
      expect((-1).padLeft(1), '-1');
      expect((-0).padLeft(2), '00');
      expect((-1).padLeft(2), '-1');
      expect((-0).padLeft(3), '000');
      expect((-1).padLeft(3), '-01');
    });
  });

  group('PartialSplit:', () {
    const maxTokens = 0xFFFFFFFF;

    group('lazySplit:', () {
      for (var testCase in _splitTestCases) {
        if (testCase.count != null) {
          continue;
        }

        test(testCase.description, () {
          var normalSplit = testCase.input.split(testCase.separator);

          assert(
            const ListEquality<String>().equals(
              testCase.expected,
              normalSplit,
            ),
          );
          assert(normalSplit.length <= maxTokens);

          expect(
            testCase.input.lazySplit(testCase.separator).toList(),
            normalSplit,
          );
        });
      }
    });

    group('partialSplit:', () {
      for (var testCase in _splitTestCases) {
        test(testCase.description, () {
          expect(
            testCase.input.partialSplit(
              testCase.separator,
              testCase.count ?? maxTokens,
            ),
            testCase.expected,
          );
        });
      }
    });
  });

  group('String.substringLoose', () {
    const s = 'Lorem ipsum';

    test('Works normally', () {
      expect(''.substringLoose(0), '');
      expect(s.substringLoose(0), s);
      expect(s.substringLoose(1), 'orem ipsum');
      expect(s.substringLoose(10), 'm');
      expect(s.substringLoose(11), '');
      expect(s.substringLoose(2, 4), 're');
      expect(s.substringLoose(4, 4), '');
    });

    test('Start index is out-of-bounds', () {
      expect(''.substringLoose(1), '');
      expect(s.substringLoose(100), '');
    });

    test('End index is out of-bounds', () {
      expect(''.substringLoose(0, 3), '');
      expect(s.substringLoose(1, 100), 'orem ipsum');
      expect(s.substringLoose(11, 100), '');
    });

    test('Start and end indices are out out-of-bounds', () {
      expect(''.substringLoose(10, 20), '');
      expect(s.substringLoose(100, 110), '');
    });

    test('End index precedes start index', () {
      expect(s.substringLoose(4, 2), '');
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

  test('bool.implies', () {
    expect(false.implies(false), true);
    expect(false.implies(true), true);
    expect(true.implies(false), false);
    expect(true.implies(true), true);
  });

  test('Future.cast', () async {
    expect(_polymorphicFuture(), isA<Future<_Derived>>());
    expect(_polymorphicFuture(), isA<Future<_Base>>());
    expect(_polymorphicFuture().cast<_Base>(), isA<Future<_Base>>());
    expect(_polymorphicFuture().cast<_Base>(), isNot(isA<Future<_Derived>>()));

    expect(
      () => _polymorphicFuture().timeout(
        const Duration(milliseconds: 1),
        onTimeout: _Base.new,
      ),
      throwsA(isA<TypeError>()),
    );

    expect(
      () => _polymorphicFuture().cast<_Base>().timeout(
        const Duration(milliseconds: 1),
        onTimeout: _Base.new,
      ),
      returnsNormally,
    );
  });

  group('PollableFuture:', () {
    test('initialized with a Future', () async {
      var pollableFuture = Future<int>.delayed(
        const Duration(seconds: 1),
        () => 42,
      ).toPollable();
      expect(pollableFuture.isCompleted, false);
      expect(() => pollableFuture.value, throwsA(isA<StateError>()));

      expect(await pollableFuture, 42);

      expect(pollableFuture.isCompleted, true);
      expect(pollableFuture.value, 42);
    });

    test('initialized with a value', () async {
      var pollableFuture = PollableFuture<int>(42);
      expect(pollableFuture.isCompleted, true);
      expect(pollableFuture.value, 42);

      expect(await pollableFuture, 42);
    });
  });

  group('DurationUtils:', () {
    const duration = Duration(
      days: 42,
      hours: 13,
      minutes: 59,
      seconds: 58,
      microseconds: 123456,
    );

    test('hoursOnly', () {
      expect(duration.hoursOnly, 13);
    });

    test('minutesOnly', () {
      expect(duration.minutesOnly, 59);
    });

    test('secondsOnly', () {
      expect(duration.secondsOnly, 58);
    });

    test('millisecondsOnly', () {
      expect(duration.millisecondsOnly, 123);
    });

    test('microsecondsOnly', () {
      expect(duration.microsecondsOnly, 456);
    });

    test('Negative duration', () {
      var negativeDuration = -duration;
      expect(negativeDuration.hoursOnly, -13);
      expect(negativeDuration.minutesOnly, -59);
      expect(negativeDuration.secondsOnly, -58);
      expect(negativeDuration.millisecondsOnly, -123);
      expect(negativeDuration.microsecondsOnly, -456);
    });
  });

  group('DateTimeStringWithOffset:', () {
    void testStringWithOffset(
      String Function(DateTime) toStringWithOffset,
      String expectedSeparator,
    ) {
      var utc = DateTime.utc(2000, 1, 2, 3, 4, 5, 6);
      expect(
        toStringWithOffset(utc),
        '2000-01-02${expectedSeparator}03:04:05.006+00:00',
      );

      var local = utc.copyWith(isUtc: false);
      var localStringWithOffset = toStringWithOffset(local);
      expect(
        DateTime.parse(localStringWithOffset).isAtSameMomentAs(local),
        true,
      );

      var offsetRegExp = RegExp(
        '2000-01-02${expectedSeparator}03:04:05.006'
        r'(?<offsetSign>[+-])'
        r'(?<offsetHours>\d{2})'
        r':'
        r'(?<offsetMinutes>\d{2})',
      );
      var match = offsetRegExp.firstMatch(localStringWithOffset);
      expect(match, isNot(null));

      match!;
      var durationString =
          '${match.namedGroup('offsetSign')}'
          '${match.namedGroup('offsetHours')}h'
          '${match.namedGroup('offsetMinutes')}m';

      expect(tryParseDuration(durationString), local.timeZoneOffset);
    }

    test('toStringWithOffset', () {
      testStringWithOffset(
        (dateTime) => dateTime.toStringWithOffset(),
        ' ',
      );
    });

    test('toIso8601StringWithOffset', () {
      testStringWithOffset(
        (dateTime) => dateTime.toIso8601StringWithOffset(),
        'T',
      );
    });
  });
}

class _Base {}

class _Derived extends _Base {}

/// Returns a [Future] that has a static type of `Future<_Base>` but that has a
/// runtime type of `Future<_Derived>`.
Future<_Base> _polymorphicFuture() =>
    Future<_Derived>.delayed(const Duration(milliseconds: 10), _Derived.new);

class _SplitTest {
  final String description;
  final String input;
  final Pattern separator;
  final int? count;
  final List<String> expected;

  const _SplitTest(
    this.description, {
    required this.input,
    required this.separator,
    required this.expected,
    this.count,
  });
}

const _splitTestCases = [
  _SplitTest(
    'Count is zero',
    input: 'a b c d e',
    separator: ' ',
    count: 0,
    expected: <String>[],
  ),
  _SplitTest(
    'Count is less than the number of split items',
    input: 'a b c d e',
    separator: ' ',
    count: 3,
    expected: ['a', 'b', 'c d e'],
  ),
  _SplitTest(
    'Count is greater than the number of split items',
    input: 'a b c d e',
    separator: ' ',
    expected: ['a', 'b', 'c', 'd', 'e'],
  ),
  _SplitTest(
    'Pattern not found',
    input: 'a b c d e',
    separator: '_',
    count: 3,
    expected: ['a b c d e'],
  ),
  _SplitTest(
    'Pattern is empty',
    input: 'abcde',
    separator: '',
    count: 3,
    expected: ['a', 'b', 'cde'],
  ),
  _SplitTest(
    'Splitting an empty string',
    input: '',
    separator: ' ',
    count: 3,
    expected: [''],
  ),
  _SplitTest(
    'Consecutive occurrences of the pattern (partial)',
    input: 'a  b   c d e',
    separator: ' ',
    count: 3,
    expected: ['a', '', 'b   c d e'],
  ),
  _SplitTest(
    'Consecutive occurrences of the pattern (full)',
    input: 'a  b   c d e',
    separator: ' ',
    expected: ['a', '', 'b', '', '', 'c', 'd', 'e'],
  ),
  _SplitTest(
    'Pattern at the beginning',
    input: ' a b c d e',
    separator: ' ',
    count: 3,
    expected: ['', 'a', 'b c d e'],
  ),
  _SplitTest(
    'Multiple occurrences of the pattern at the beginning (partial)',
    input: '  a b c d e',
    separator: ' ',
    count: 3,
    expected: ['', '', 'a b c d e'],
  ),
  _SplitTest(
    'Multiple occurrences of the pattern at the beginning (full)',
    input: '  a b c d e',
    separator: ' ',
    expected: ['', '', 'a', 'b', 'c', 'd', 'e'],
  ),
  _SplitTest(
    'Pattern at the end (partial)',
    input: 'a b c d e ',
    separator: ' ',
    count: 3,
    expected: ['a', 'b', 'c d e '],
  ),
  _SplitTest(
    'Pattern at the end (full)',
    input: 'a b c d e ',
    separator: ' ',
    expected: ['a', 'b', 'c', 'd', 'e', ''],
  ),
  _SplitTest(
    'Multiple occurrences of the pattern at the end',
    input: 'a b c d e  ',
    separator: ' ',
    expected: ['a', 'b', 'c', 'd', 'e', '', ''],
  ),
];
