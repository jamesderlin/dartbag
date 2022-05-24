import 'package:dartbag/timer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

void main() {
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
