import 'dart:async';

import 'dart:math' show Random;
import 'dart:typed_data';

import 'package:dartbag/debug.dart';
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
  var random = Random(0);

  // Generate random data.
  //
  // 100 MB minus a few bytes to avoid being an exact multiple of 8 bytes.
  const numBytes = 100 * 1000 * 1000 - 3;
  var data = Uint8List.fromList([
    for (var i = 0; i < numBytes; i += 1) random.nextInt(256),
  ]);

  void testMemEquals(bool Function(Uint8List, Uint8List) memEquals) {
    test('memEquals behaves correctly for equal lists', () {
      // ignore: discarded_futures
      usuallyPasses(
        tryCount: 10,
        minimumPassCount: 7,
        () {
          var dataCopy = Uint8List.fromList(data);

          late bool result;
          var naiveDuration = timeOperation(
            () => result = listEquals(data, dataCopy),
          );
          expect(result, true);

          var wordDuration = timeOperation(
            () => result = memEquals(data, dataCopy),
          );
          expect(result, true);

          expect(wordDuration, lessThan(naiveDuration));

          var speedup =
              naiveDuration.inMicroseconds / wordDuration.inMicroseconds;
          print(
            'naive:     ${naiveDuration.toReadableString()}\n'
            'memEquals: ${wordDuration.toReadableString()}\n'
            'Speedup:   ${speedup.toStringAsFixed(1)}x',
          );
        },
      );
    });

    test('memEquals behaves correctly for unequal lists of equal lengths', () {
      // ignore: discarded_futures
      usuallyPasses(
        tryCount: 10,
        minimumPassCount: 7,
        () {
          var dataCopy = Uint8List.fromList(data);
          dataCopy[numBytes - 1] += 1;

          late bool result;
          var naiveDuration = timeOperation(
            () => result = listEquals(data, dataCopy),
          );
          expect(result, false);

          var wordDuration = timeOperation(
            () => result = memEquals(data, dataCopy),
          );
          expect(result, false);

          expect(wordDuration, lessThan(naiveDuration));

          var speedup =
              naiveDuration.inMicroseconds / wordDuration.inMicroseconds;
          print(
            'naive:     ${naiveDuration.toReadableString()}\n'
            'memEquals: ${wordDuration.toReadableString()}\n'
            'Speedup:   ${speedup.toStringAsFixed(1)}x',
          );
        },
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

/// Runs a test [body] a specified number of times, checking that the test
/// passes a minimum number of times.
///
/// If [minimumPassCount] is not specified, [body] will be expected to succeed
/// strictly more than 50% of the time.
///
/// If [body] is asynchronous (that is, returns a [Future]), `usuallyPasses`
/// also will be asynchronous and will return a `Future<void>`.  If [body] is
/// synchronous, `usuallyPasses` will complete synchronously.
FutureOr<void> usuallyPasses<R>(
  R Function() body, {
  required int tryCount,
  int? minimumPassCount,
}) async {
  assert(tryCount > 0);
  minimumPassCount ??= ((tryCount / 2) + 1).floor();
  assert(minimumPassCount <= tryCount);

  var passCount = 0;

  TestFailure? lastFailure;
  StackTrace? lastStackTrace;

  for (var i = 0; i < tryCount && passCount < minimumPassCount; i += 1) {
    try {
      var result = body();
      if (isSubtype<R, Future<dynamic>>()) {
        await (result as Future);
      }
      passCount += 1;
    } on TestFailure catch (e, st) {
      lastFailure = e;
      lastStackTrace = st;
    }
  }

  if (passCount < minimumPassCount) {
    var failureCount = tryCount - passCount;
    var maximumFailureCount = tryCount - minimumPassCount;

    Error.throwWithStackTrace(
      TestFailure(
        'Failed $failureCount out of $tryCount times. '
        '(Maximum allowed failures: $maximumFailureCount) Last failure:\n'
        '$lastFailure',
      ),
      lastStackTrace!,
    );
  }
}
