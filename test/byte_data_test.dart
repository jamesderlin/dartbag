import 'dart:math' show Random;
import 'dart:typed_data';

import 'package:dartbag/byte_data.dart';

import 'package:test/test.dart';

void main() {
  var random = Random(0);

  // Generate random data.
  //
  // 100 MB minus a few bytes to avoid being an exact multiple of 8 bytes.
  const numBytes = 100 * 1000 * 1000 - 3;
  var data = Uint8List.fromList([
    for (var i = 0; i < numBytes; i += 1) random.nextInt(256),
  ]);

  test('memEquals behaves correctly for equal lists', () {
    var dataCopy = Uint8List.fromList(data);
    expect(memEquals(data, dataCopy), true);
  });

  test('memEquals behaves correctly for unequal lists of equal lengths', () {
    var dataCopy = Uint8List.fromList(data);
    dataCopy[numBytes - 1] += 1;
    expect(memEquals(data, dataCopy), false);
  });

  test('memEquals behaves correctly for lists of unequal lengths', () {
    var dataCopy = Uint8List.fromList(data.take(data.length - 1).toList());
    expect(memEquals(data, dataCopy), false);
  });
}
