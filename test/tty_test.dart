@TestOn('vm')

import 'package:args/args.dart';
import 'package:dartbag/matcher.dart';
import 'package:dartbag/parse.dart';
import 'package:dartbag/tty.dart';
import 'package:test/test.dart';

void main() {
  group('wordWrap:', () {
    test('Unindented', () {
      expect(
        wordWrap('The quick brown fox jumps over the lazy dog.', 10),
        'The quick\n'
        'brown fox\n'
        'jumps over\n'
        'the lazy\n'
        'dog.',
      );

      expect(
        wordWrap('Jackdaws\nlove\nmy big sphinx of quartz.', 10),
        'Jackdaws\n'
        'love\n'
        'my big\n'
        'sphinx of\n'
        'quartz.',
      );

      expect(
        wordWrap('abc', 1),
        'a\n'
        'b\n'
        'c',
      );

      expect(
        wordWrap('abcdefghijklmnopqrstuvwxyz', 10),
        'abcdefghij\n'
        'klmnopqrst\n'
        'uvwxyz',
      );

      expect(
        wordWrap('abc    defghijklmnopqrstuvwxyz', 10),
        'abc\n'
        'defghijklm\n'
        'nopqrstuvw\n'
        'xyz',
      );
    });

    test('hangingIndent', () {
      expect(
        wordWrap(
          'The quick brown fox jumps over the lazy dog.',
          10,
          hangingIndent: 2,
        ),
        'The quick\n'
        '  brown\n'
        '  fox\n'
        '  jumps\n'
        '  over the\n'
        '  lazy\n'
        '  dog.',
      );

      expect(
        wordWrap(
          'Jackdaws\nlove\nmy big sphinx of quartz.',
          10,
          hangingIndent: 2,
        ),
        'Jackdaws\n'
        '  love\n'
        '  my big\n'
        '  sphinx\n'
        '  of\n'
        '  quartz.',
      );

      expect(
        wordWrap('abcd', 2, hangingIndent: 1),
        'ab\n'
        ' c\n'
        ' d',
      );

      expect(
        wordWrap('abcdefghijklmnopqrstuvwxyz', 10, hangingIndent: 2),
        'abcdefghij\n'
        '  klmnopqr\n'
        '  stuvwxyz',
      );

      expect(
        wordWrap('abc    defghijklmnopqrstuvwxyz', 10, hangingIndent: 2),
        'abc\n'
        '  defghijk\n'
        '  lmnopqrs\n'
        '  tuvwxyz',
      );
    });
  });

  group('ArgResults.parseOptionValue:', () {
    var argParser = ArgParser()
      ..addOption('int')
      ..addFlag('flag');

    test('Works with options', () {
      var argResults = argParser.parse(['--int', '42']);
      var value = argResults.parseOptionValue('int', int.tryParse);
      expect(value, 42);

      // TODO: Check exception messages.
      argResults = argParser.parse(['--int', '']);
      expect(
        () => argResults.parseOptionValue('int', int.tryParse),
        throwsA(
          toStringMatches<ArgParserException>(
            contains('Invalid value for "int": ""'),
          ),
        ),
      );

      argResults = argParser.parse(['--int', '0.0']);
      expect(
        () => argResults.parseOptionValue('int', int.tryParse),
        throwsA(
          toStringMatches<ArgParserException>(
            contains('Invalid value for "int": "0.0"'),
          ),
        ),
      );

      argResults = argParser.parse(['--int', 'foo']);
      expect(
        () => argResults.parseOptionValue('int', int.tryParse),
        throwsA(
          toStringMatches<ArgParserException>(
            contains('Invalid value for "int": "foo"'),
          ),
        ),
      );
    });
    test('Works with flags', () {
      var argResults = argParser.parse(['--flag']);
      expect(argResults.parseOptionValue('flag', tryParseBool), true);

      argResults = argParser.parse(['--no-flag']);
      expect(argResults.parseOptionValue('flag', tryParseBool), false);
    });
  });
}
