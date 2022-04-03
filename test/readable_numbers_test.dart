import 'dart:math';

import 'package:dart_utils/readable_numbers.dart';
import 'package:test/test.dart';

void main() {
  group('readableNumber:', () {
    test('Large non-negative numbers', () {
      expect(0.toReadableString(), '0');
      expect(0.toReadableString(unit: 'B'), '0 B');

      expect(999.toReadableString(), '999');
      expect(1000.toReadableString(), '1 K');
      expect(1000.toReadableString(binary: true), '1000');

      expect(1000.toReadableString(unit: 'B'), '1 KB');
      expect(1000.toReadableString(unit: 'B', binary: true), '1000 B');

      expect(pow(1024.0, 2).toReadableString(unit: 'B'), '1 MB');
      expect(pow(1024.0, 2).toReadableString(unit: 'B', binary: true), '1 MiB');

      expect(
        pow(1024.0, 2).toReadableString(precision: 2, unit: 'B'),
        '1.05 MB',
      );
      expect(
        pow(1024.0, 3).toReadableString(precision: 2, unit: 'B'),
        '1.07 GB',
      );
      expect(
        pow(1024.0, 4).toReadableString(precision: 2, unit: 'B'),
        '1.10 TB',
      );
      expect(
        pow(1024.0, 5).toReadableString(precision: 2, unit: 'B'),
        '1.13 PB',
      );
      expect(
        pow(1024.0, 6).toReadableString(precision: 2, unit: 'B'),
        '1.15 EB',
      );

      expect(
        pow(1024.0, 7).toReadableString(precision: 2, unit: 'B'),
        '1.18 ZB',
      );
      expect(
        pow(1024.0, 8).toReadableString(precision: 2, unit: 'B'),
        '1.21 YB',
      );
      expect(
        pow(1024.0, 9).toReadableString(precision: 2, unit: 'B'),
        '1237.94 YB',
      );

      expect(
        (1.5 * pow(1000.0, 9)).toReadableString(
          precision: 2,
          unit: 'B',
          binary: true,
        ),
        '1240.77 YiB',
      );
    });

    test('Negative numbers', () {
      expect((-999).toReadableString(), '-999');
      expect((-1000).toReadableString(), '-1 K');
      expect((-1000).toReadableString(binary: true), '-1000');

      expect((-pow(1024.0, 2)).toReadableString(unit: 'B'), '-1 MB');
      expect(
        (-pow(1024.0, 2)).toReadableString(unit: 'B', binary: true),
        '-1 MiB',
      );
    });
  });

  group('readableDuration:', () {
    test('0s', () {
      expect(Duration.zero.toReadableString(), '0s');
    });

    test('1s', () {
      expect(const Duration(seconds: 1).toReadableString(), '1s');
    });

    test('Subseconds', () {
      expect(const Duration(milliseconds: 100).toReadableString(), '0.1s');
      expect(const Duration(milliseconds: 10).toReadableString(), '0.01s');
      expect(const Duration(milliseconds: 1).toReadableString(), '0.001s');
      expect(const Duration(microseconds: 100).toReadableString(), '0.0001s');
      expect(const Duration(microseconds: 10).toReadableString(), '0.00001s');
      expect(const Duration(microseconds: 1).toReadableString(), '0.000001s');
    });

    test('All components', () {
      expect(
        const Duration(days: 1, hours: 2, minutes: 3, seconds: 4)
            .toReadableString(),
        '1d2h3m4s',
      );
      expect(
        const Duration(days: 1, hours: 2, minutes: 34, seconds: 56)
            .toReadableString(),
        '1d2h34m56s',
      );
    });

    test('Missing components', () {
      expect(
        const Duration(hours: 1, seconds: 2).toReadableString(),
        '1h2s',
      );
      expect(
        const Duration(hours: 1, milliseconds: 500).toReadableString(),
        '1h0.5s',
      );
    });
  });
}
