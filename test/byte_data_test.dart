import 'dart:math' show Random;
import 'dart:typed_data';

import 'package:dartbag/misc.dart';
import 'package:dartbag/readable_numbers.dart';
import 'package:dartbag/src/mem_equals32.dart' as mem_equals32;
import 'package:dartbag/src/mem_equals64.dart' as mem_equals64;

import 'package:test/test.dart';

/// Naive [List] equality implementation.
bool listEquals<E>(List<E> list1, List<E> list2) {
  if (identical(list1, list2)) {
    return true;
  }

  if (list1.length != list2.length) {
    return false;
  }

  for (var i = 0; i < list1.length; i += 1) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}

void main() {
  var random = Random();

  // Generate random data.
  //
  // 100 MB minus a few bytes to avoid being an exact multiple of 8 bytes.
  const numBytes = 100 * 1000 * 1000 - 3;
  var data = Uint8List.fromList([
    for (var i = 0; i < numBytes; i += 1) random.nextInt(256),
  ]);

  void testMemEquals(bool Function(Uint8List, Uint8List) memEquals) {
    test('memEquals behaves correctly for equal lists', () {
      var dataCopy = Uint8List.fromList(data);

      late bool result;
      var naiveDuration =
          timeOperation(() => result = listEquals(data, dataCopy));
      expect(result, true);

      var wordDuration =
          timeOperation(() => result = memEquals(data, dataCopy));
      expect(result, true);

      expect(wordDuration, lessThan(naiveDuration));

      var speedup = naiveDuration.inMicroseconds / wordDuration.inMicroseconds;
      print(
        'naive:     ${naiveDuration.toReadableString()}\n'
        'memEquals: ${wordDuration.toReadableString()}\n'
        'Speedup:   ${speedup.toStringAsFixed(1)}x',
      );
    });

    test('memEquals behaves correctly for unequal lists of equal lengths', () {
      var dataCopy = Uint8List.fromList(data);
      dataCopy[numBytes - 1] += 1;

      late bool result;
      var naiveDuration =
          timeOperation(() => result = listEquals(data, dataCopy));
      expect(result, false);

      var wordDuration =
          timeOperation(() => result = memEquals(data, dataCopy));
      expect(result, false);

      expect(wordDuration, lessThan(naiveDuration));

      var speedup = naiveDuration.inMicroseconds / wordDuration.inMicroseconds;
      print(
        'naive:     $naiveDuration\n'
        'memEquals: $wordDuration\n'
        'Speedup:   ${speedup.toStringAsFixed(1)}x',
      );
    });

    test('memEquals behaves correctly for lists of unequal lengths', () {
      var dataCopy = Uint8List.fromList(data.take(data.length - 1).toList());
      expect(memEquals(data, dataCopy), false);
    });
  }

  group('memEquals (32-bit):', () {
    testMemEquals(mem_equals32.memEquals);
  });

  group(
    'memEquals (64-bit):',
    onPlatform: {'browser': const Skip()},
    () {
      testMemEquals(mem_equals64.memEquals);
    },
  );
}
