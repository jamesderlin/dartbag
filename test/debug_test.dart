import 'package:dartbag/debug.dart';
import 'package:path/path.dart' as pathlib;
import 'package:test/test.dart';

void main() {
  test(
    'currentDartFilePath:',
    onPlatform: {'browser': const Skip()},
    () {
      var path = currentDartFilePath();
      expect(pathlib.isAbsolute(path), true);
      expect(path, contains(pathlib.context.separator));
      expect(normalizeSeparators(path), endsWith('/test/debug_test.dart'));

      path = currentDartFilePath(packageRelative: true);
      expect(path, contains(pathlib.context.separator));
      expect(normalizeSeparators(path), 'test/debug_test.dart');
    },
  );

  test('staticType', () {
    var someInt = 0;
    var someString = '';
    expect(someInt.staticType, int);
    expect(someString.staticType, String);

    num someNum = someInt;
    expect(someNum.runtimeType, int);
    expect(someNum.staticType, num);
  });

  test('asserts are enabled in tests', () {
    expect(assertsEnabled, true);
  });

  group('String.escape', () {
    test('Escapes properly', () {
      const testCases = [
        ('Hello world!', 'Hello world!'),
        ('\u2665', r'\u{2665}'),
        ('\u{1f600}', r'\u{1f600}'),
        ('\u{0}', r'\u{0}'),
        ('\r\n\b\t\v\f', r'\r\n\b\t\v\f'),
        (r'\', r'\\'),
        (r'$doNotInterpolate', r'\$doNotInterpolate'),
      ];

      for (var (input, expected) in testCases) {
        expect(
          input.escape(quotes: QuoteType.none, ascii: true),
          expected,
        );

        expect(
          input.escape(quotes: QuoteType.single, ascii: true),
          "'$expected'",
        );

        expect(
          input.escape(quotes: QuoteType.double, ascii: true),
          '"$expected"',
        );
      }
    });

    test('Unicode characers can be unescaped', () {
      expect(
        '\u2665'.escape(quotes: QuoteType.single, ascii: false),
        "'\u2665'",
      );
    });

    test('Embedded quotes are properly escaped', () {
      expect(r'"'.escape(quotes: QuoteType.none), r'"');
      expect(r'"'.escape(quotes: QuoteType.single), "'\"'");
      expect(r'"'.escape(quotes: QuoteType.double), r'"\""');

      expect(r"'".escape(quotes: QuoteType.none), r"'");
      expect(r"'".escape(quotes: QuoteType.single), r"'\''");
      expect(r"'".escape(quotes: QuoteType.double), '"\'"');
    });
  });
}

/// Normalizes directory separators to the POSIX style.
String normalizeSeparators(String path) => path.replaceAll(r'\', '/');
