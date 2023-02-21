/// Custom [Matcher]s for tests.
library;

import 'package:matcher/matcher.dart';

/// Returns a [Matcher] that matches if the value is of a specified type and if
/// its [Object.toString] representation matches [valueOrMatcher].
///
/// Example:
/// ```dart
/// void throwIfEven(int x) {
///   if (x.isEven) {
///     throw ArgumentError('$x is even');
///   }
/// }
///
/// test('Example test', () {
///   expect(
///     () => throwIfEven(42),
///       throwsA(toStringMatches<ArgumentError>(contains('42'))),
///   );
/// });
/// ```
///
// This alternatively could be implemented by using [allOf] to combine an
// [isA<T>] matcher with a [CustomMatcher] that matches against the result of
// [Object.toString].  However, implementing our own [Matcher] gives us more
// control over the failure message.
Matcher toStringMatches<T>(Object valueOrMatcher) =>
    _StringMatcher<T>(valueOrMatcher);

class _StringMatcher<T> extends Matcher {
  final Matcher _nestedMatcher;

  _StringMatcher(Object valueOrMatcher)
      : _nestedMatcher = (valueOrMatcher is Matcher)
            ? valueOrMatcher
            : wrapMatcher(valueOrMatcher);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! T) {
      matchState[null] = 'is not a $T.';
      return false;
    }

    var nestedMatchState = <dynamic, dynamic>{};
    matchState[_nestedMatcher] = nestedMatchState;

    var s = item.toString();
    matchState[null] = s;
    return _nestedMatcher.matches(s, nestedMatchState);
  }

  @override
  Description describe(Description description) => description
      .add('a $T whose string representation ')
      .addDescriptionOf(_nestedMatcher);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    var s = matchState[null];
    var nestedMatchState = matchState[_nestedMatcher];
    if (nestedMatchState is Map<dynamic, dynamic>) {
      return _nestedMatcher.describeMismatch(
        s,
        mismatchDescription,
        nestedMatchState,
        verbose,
      );
    }

    return mismatchDescription.add(s as String);
  }
}
