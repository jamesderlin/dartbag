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
}

/// Normalizes directory separators to the POSIX style.
String normalizeSeparators(String path) => path.replaceAll(r'\', '/');
