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
          contains(
            'Expected: a _MyException '
            "whose string representation contains 'baz'",
          ),
          contains('Actual: _MyException:<foobar>'),
        ),
      );

      expectFailure(
        () => expect(
          'foobar',
          toStringMatches<_MyException>(contains('foo')),
        ),
        allOf(
          contains(
            'Expected: a _MyException '
            "whose string representation contains 'foo'",
          ),
          contains('Which: is not a _MyException'),
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
