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
Matcher toStringMatches<T>(Object valueOrMatcher) => isA<T>().having(
  (object) => object.toString(),
  'toString()',
  valueOrMatcher,
);
