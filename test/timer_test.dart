import 'package:dartbag/timer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

void main() {
  group('RestartableTimer', () {
    const defaultDuration = Duration(seconds: 10);
    const oneMillisecond = Duration(milliseconds: 1);

    late int counter;
    late RestartableTimer timer;

    // We can't use [setUp] because the [Timer] must be created within the
    // [FakeAsync] zone.  References:
    // * https://github.com/flutter/flutter/issues/57600
    // * https://github.com/dart-lang/test/issues/1023
    void initTimer() {
      counter = 0;
      timer = RestartableTimer(defaultDuration, () => counter += 1);
    }

    test('Works normally', () {
      fakeAsync((async) {
        initTimer();
        expect(counter, 0);

        async.elapse(defaultDuration - oneMillisecond);
        expect(counter, 0);
        expect(timer.isActive, true);

        async.elapse(oneMillisecond);
        expect(counter, 1);
        expect(timer.isActive, false);

        async.elapse(defaultDuration * 2);
        expect(counter, 1);
      });
    });

    test('Can be restarted after expiring', () {
      fakeAsync((async) {
        initTimer();

        async.elapse(defaultDuration);
        expect(counter, 1);
        expect(timer.isActive, false);

        timer.restart();
        expect(counter, 1);
        expect(timer.isActive, true);

        async.elapse(defaultDuration - oneMillisecond);
        expect(counter, 1);
        expect(timer.isActive, true);

        async.elapse(oneMillisecond);
        expect(counter, 2);
        expect(timer.isActive, false);
      });
    });

    test('Can be restarted before expiring', () {
      fakeAsync((async) {
        initTimer();

        async.elapse(defaultDuration - oneMillisecond);
        expect(counter, 0);
        expect(timer.isActive, true);

        timer.restart();
        expect(counter, 0);
        expect(timer.isActive, true);

        async.elapse(defaultDuration - oneMillisecond);
        expect(counter, 0);
        expect(timer.isActive, true);

        async.elapse(oneMillisecond);
        expect(counter, 1);
        expect(timer.isActive, false);
      });
    });

    test('Cancellation works', () {
      fakeAsync((async) {
        initTimer();

        expect(timer.isActive, true);
        timer.cancel();
        expect(timer.isActive, false);

        async.elapse(const Duration(seconds: 60));
        expect(counter, 0);

        timer.restart();
        expect(counter, 0);
        expect(timer.isActive, true);

        async.elapse(const Duration(seconds: 10));
        expect(counter, 1);
        expect(timer.isActive, false);
      });
    });
  });

  group('ExpiringPeriodicTimer', () {
    test('Works normally (total is an exact multiple of interval)', () {
      fakeAsync((async) {
        var counter = 0;
        Duration? lastTimeLeft;
        var timer = ExpiringPeriodicTimer(
          total: const Duration(seconds: 30),
          interval: const Duration(seconds: 5),
          onTick: (timeLeft) {
            lastTimeLeft = timeLeft;
            counter += 1;
          },
          onFinish: () => counter += 100,
        );
        expect(counter, 0);
        expect(lastTimeLeft, null);

        async.elapse(const Duration(seconds: 4));
        expect(counter, 0);
        expect(lastTimeLeft, null);
        expect(timer.isActive, true);

        async.elapse(const Duration(seconds: 1));
        expect(counter, 1);
        expect(lastTimeLeft, const Duration(seconds: 25));
        expect(timer.isActive, true);

        async.elapse(const Duration(seconds: 5));
        expect(counter, 2);
        expect(lastTimeLeft, const Duration(seconds: 20));
        expect(timer.isActive, true);

        async.elapse(const Duration(seconds: 19));
        expect(counter, 5);
        expect(lastTimeLeft, const Duration(seconds: 5));
        expect(timer.isActive, true);

        async.elapse(const Duration(seconds: 1));
        expect(counter, 106);
        expect(lastTimeLeft, Duration.zero);
        expect(timer.isActive, false);
      });
    });

    test('Works normally (total is not a multiple of interval)', () {
      fakeAsync((async) {
        var counter = 0;
        Duration? lastTimeLeft;
        var timer = ExpiringPeriodicTimer(
          total: const Duration(seconds: 10),
          interval: const Duration(seconds: 4),
          onTick: (timeLeft) {
            lastTimeLeft = timeLeft;
            counter += 1;
          },
          onFinish: () => counter += 100,
        );
        expect(counter, 0);
        expect(lastTimeLeft, null);

        async.elapse(const Duration(seconds: 10));
        expect(counter, 102);
        expect(lastTimeLeft, const Duration(seconds: 2));
        expect(timer.isActive, false);
      });
    });

    test('Cancellation works', () {
      fakeAsync((async) {
        var counter = 0;
        Duration? lastTimeLeft;
        var timer = ExpiringPeriodicTimer(
          total: const Duration(seconds: 10),
          interval: const Duration(seconds: 5),
          onTick: (timeLeft) {
            lastTimeLeft = timeLeft;
            counter += 1;
          },
          onFinish: () => counter += 100,
        );
        expect(counter, 0);
        expect(lastTimeLeft, null);

        async.elapse(const Duration(seconds: 1));
        expect(timer.isActive, true);
        timer.cancel();
        expect(timer.isActive, false);

        async.elapse(const Duration(seconds: 10));
        expect(counter, 0);
        expect(lastTimeLeft, null);
      });
    });
  });
}
