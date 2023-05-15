import 'package:dartbag/matcher.dart';
import 'package:test/test.dart';

void main() {
  group('toStringMatches:', () {
    test('', () {
      expect(_MyException('foobar'), toStringMatches<_MyException>('foobar'));

      expect(
        _MyException('foobar'),
        toStringMatches<_MyException>(contains('foobar')),
      );

      expectFailure(
        () => expect(
          _MyException('foobar'),
          toStringMatches<_MyException>(contains('baz')),
        ),
        allOf(
          matches(
            RegExp(
              multiLine: true,
              r'^\s*Expected: .*_MyException.*'
              r" with `toString\(\)`.* contains 'baz'",
            ),
          ),
          matches(
            RegExp(
              multiLine: true,
              r'^\s*Actual: _MyException:<foobar>',
            ),
          ),
        ),
      );

      expectFailure(
        () => expect(
          'foobar',
          toStringMatches<_MyException>(contains('foo')),
        ),
        allOf(
          matches(
            RegExp(
              multiLine: true,
              r'^\s*Expected: .*_MyException.*'
              r" with `toString\(\)`.* contains 'foo'",
            ),
          ),
          matches(
            RegExp(
              multiLine: true,
              r"^\s*Which: is not an instance of '_MyException'",
            ),
          ),
        ),
      );
    });
  });
}

/// Asserts that executing [expectation] fails with a failure message that
/// matches [failureMessageMatcher].
void expectFailure(void Function() expectation, Matcher failureMessageMatcher) {
  try {
    expectation();
  } on TestFailure catch (e) {
    expect(e.message, failureMessageMatcher);
    return;
  }
  fail('Failed to fail.');
}

/// A simple [Exception] class.
class _MyException implements Exception {
  _MyException(this.message);

  final String message;

  @override
  String toString() => message;
}
