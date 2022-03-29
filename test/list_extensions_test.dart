import 'dart:collection';
import 'dart:math';

import 'package:dart_utils/list_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('reverse:', () {
    test('empty List', () {
      var list = <int>[]..reverse();
      expect(list, <int>[]);
    });

    test('List with 1 element', () {
      var list = [1]..reverse();
      expect(list, [1]);
    });

    test('List with an even length', () {
      var list = [1, 2, 3, 4]..reverse();
      expect(list, [4, 3, 2, 1]);
    });

    test('List with an odd length', () {
      var list = [1, 2, 3, 4, 5]..reverse();
      expect(list, [5, 4, 3, 2, 1]);
    });
  });

  group('sortWithKey:', () {
    final random = Random(0);
    final ordered =
        UnmodifiableListView([for (var i = 0; i < 1000; i += 1) '$i']);
    final shuffled = UnmodifiableListView(ordered.toList()..shuffle(random));

    test('Sorts correctly', () {
      expect(<String>[]..sortWithKey(int.parse), <String>[]);

      var shuffledCopy = shuffled.toList()..sortWithKey(int.parse);
      expect(shuffledCopy, ordered);
    });

    test('Sorts efficiently', () {
      var trackedParseCallCount = 0;

      int trackedParse(String string) {
        trackedParseCallCount += 1;
        return int.parse(string);
      }

      var stopwatch = Stopwatch()..start();
      shuffled.toList().sort((a, b) {
        var valueA = trackedParse(a);
        var valueB = trackedParse(b);
        return valueA.compareTo(valueB);
      });
      var regularDuration = stopwatch.elapsed;

      var regularCallCount = trackedParseCallCount;
      trackedParseCallCount = 0;

      stopwatch
        ..reset()
        ..start();
      shuffled.toList().sortWithKey(trackedParse);
      var keyDuration = stopwatch.elapsed;

      var keyCallCount = trackedParseCallCount;

      expect(keyCallCount, lessThan(regularCallCount));
      expect(keyDuration, lessThan(regularDuration));

      var speedup = regularDuration.inMicroseconds / keyDuration.inMicroseconds;
      print(
        'List.sort() element conversion count:        $regularCallCount\n'
        'List.sortWithKey() element conversion count: $keyCallCount\n'
        'List.sort() duration:        $regularDuration\n'
        'List.sortWithKey() duration: $keyDuration\n'
        'Speedup: ${speedup.toStringAsFixed(1)}x',
      );
    });
  });
}
