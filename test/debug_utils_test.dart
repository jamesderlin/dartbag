import 'package:dart_utils/debug_utils.dart';
import 'package:test/test.dart';

void main() {
  test(
    'currentDartPackagePath',
    onPlatform: {'browser': const Skip()},
    () {
      expect(currentDartPackagePath(), 'test/debug_utils_test.dart');
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
