/// Utilities to make debugging easier.
library;

import 'dart:async';

import 'package:charcode/charcode.dart';
import 'package:stack_trace/stack_trace.dart' as stacktrace;

/// Returns the path to the caller's `.dart` file.
///
/// If [packageRelative] is true, returns a path relative to the package root.
///
/// If [packageRelative] is false, returns an absolute path.
///
/// This does not work for Dart for the Web.
///
/// Note that [Platform.script] does not work for `import`ed files and
/// consequently does not work with the Dart test runner.
///
/// [Platform.script]: https://api.dart.dev/stable/dart-io/Platform/script.html
String currentDartFilePath({bool packageRelative = false}) {
  var caller = stacktrace.Frame.caller(1);
  return packageRelative ? caller.library : caller.uri.toFilePath();
}

/// Provides a [staticType] getter on all non-`dynamic` objects.
extension StaticTypeExtension<T> on T {
  /// Returns the static type of this object.
  ///
  /// This can be used to report the static type of an object (which might not
  /// always be obvious due to inference or when dealing with generics), which
  /// might be different from [Object.runtimeType].
  Type get staticType => T;
}

/// Returns true if `assert` is enabled.
bool get assertsEnabled {
  var result = false;
  assert(
    () {
      result = true;
      return true;
    }(),
  );
  return result;
}

/// Times the specified synchronous operation.
Duration timeOperation(void Function() operation) {
  var stopwatch = Stopwatch()..start();
  operation();
  return stopwatch.elapsed;
}

/// Times the specified asynchronous operation.
Future<Duration> timeAsyncOperation(Future<void> Function() operation) async {
  var stopwatch = Stopwatch()..start();
  await operation();
  return stopwatch.elapsed;
}

/// The type of surrounding quotes to use when generating escaped strings.
///
/// See [EscapeString.escape].
enum QuoteType {
  /// Do not use surrounding quotes.
  none,

  /// Use single-quotes.
  single,

  /// Use double-quotes.
  double,
}

/// Provides an [escape] extension method on [Runes].
extension EscapeRunes on Runes {
  /// A generator that escapes this [Runes].
  ///
  /// See [EscapeString.escape] for parameter details.
  Iterable<int> escape({
    QuoteType quotes = QuoteType.single,
    bool ascii = false,
  }) sync* {
    var quote = switch (quotes) {
      QuoteType.none => null,
      QuoteType.single => $singleQuote,
      QuoteType.double => $doubleQuote,
    };

    if (quote != null) {
      yield quote;
    }

    for (var rune in this) {
      switch (rune) {
        case $lf:
          yield $backslash;
          yield $n;
        case $cr:
          yield $backslash;
          yield $r;
        case $bs:
          yield $backslash;
          yield $b;
        case $tab:
          yield $backslash;
          yield $t;
        case $vt:
          yield $backslash;
          yield $v;
        case $ff:
          yield $backslash;
          yield $f;
        case $backslash:
        case $dollar:
          yield $backslash;
          yield rune;
        default:
          if (rune == quote) {
            yield $backslash;
          }

          var isControlCharacter =
              rune <= 0x1F || rune == 0x7F || (rune >= 0x80 && rune <= 0x9F);

          if (!isControlCharacter && (rune < 128 || !ascii)) {
            yield rune;
          } else {
            yield $backslash;
            yield $u;
            yield $openBrace;
            yield* rune.toRadixString(16).runes;
            yield $closeBrace;
          }
      }
    }

    if (quote != null) {
      yield quote;
    }
  }
}

/// Provides an [escape] extension method on [String].
extension EscapeString on String {
  /// Escapes a [String] such that it can be used as a string literal in
  /// generated code.
  ///
  /// [quotes] specifies the type of surrounding quotes to add.  Existing
  /// occurrences of the specified quote character will be escaped.
  ///
  /// If [ascii] is true, all non-ASCII code-points will be escaped as a
  /// Unicode literal sequence (`\u{XXXXXX}`).
  ///
  /// Calling [jsonEncode] on a [String] is similar, but [escape] has some
  /// notable differences:
  ///
  /// * [jsonEncode] always uses surrounding double-quotes.
  /// * [jsonEncode] does not escape `$`, which is used in Dart string literals
  ///   for string interpolation.
  /// * [jsonEncode] usually does not escape non-ASCII characters.
  /// * [jsonEncode] escapes a vertical tab (`\v') as `\u000b`.
  /// * If there is no canonical escape sequence for a character that needs to
  ///   be escaped (such as (`\n`, `\t`, etc.), [jsonEncode] encodes the
  ///   character as `\uXXXX` (which represents a UTF-16 code unit) whereas
  ///   [escape] uses `\u{XXXXXX}` (which represents a Unicode code point).
  ///
  /// In summary, comparing `jsonEncode` to `escape` (when called with
  /// default arguments):
  ///
  /// |    Input    | `jsonEncode` |   `escape`   |
  /// |:-----------:|:------------:|:------------:|
  /// |     '$'     |     r"$"     |    r'\$'     |
  /// |    '\v'     |  r"\u000b"   |    r'\v'     |
  /// |  '\u0000'   |  r"\u0000"   |   r'\u{0}'   |
  /// |  '\u2665'   |     r"♥"     | r'\u{2665}'  |
  /// | '\u{1f600}' |     r"😀"     | r'\u{1f600}' |
  ///
  String escape({
    QuoteType quotes = QuoteType.single,
    bool ascii = true,
  }) => String.fromCharCodes(
    runes.escape(quotes: quotes, ascii: ascii),
  );
}
