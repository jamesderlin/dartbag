import 'package:dart_utils/parse_utils.dart';
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
}
