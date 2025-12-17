import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/features/worklog/repository/mock_work_log_repository.dart';

void main() {
  group('WorkLogRepository Rebuild Efficiency', () {
    late MockWorkLogRepository repo;

    setUp(() {
      repo = MockWorkLogRepository();
      repo.clearLogs();
    });

    tearDown(() {
      repo.dispose();
    });

    group('Baseline (Current Behavior)', () {
      test('watchWorkLogs() emits entire collection on any change', () async {
        final log1 = LogEntry(
          id: 'log-1',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
          user: 'user-a',
          date: DateTime.now(),
        );
        final log2 = LogEntry(
          id: 'log-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          date: DateTime.now(),
        );

        await repo.upsertWorkLog(log1);
        await repo.upsertWorkLog(log2);

        int emissionCount = 0;
        final subscription = repo.watchWorkLogs().listen((_) {
          emissionCount++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        emissionCount = 0;

        await repo.upsertWorkLog(log1.copyWith(count: 7));
        await Future.delayed(Duration(milliseconds: 50));

        expect(emissionCount, greaterThan(0));

        subscription.cancel();
      });
    });

    group('Fine-Grained (Target Behavior)', () {
      test('watchWorkLogsByDateRange() emits only when logs in range change', () async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(Duration(days: 1));

        final todayLog = LogEntry(
          id: 'log-today',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
          user: 'user-a',
          date: today,
        );
        final yesterdayLog = LogEntry(
          id: 'log-yesterday',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          date: yesterday,
        );

        await repo.upsertWorkLog(todayLog);
        await repo.upsertWorkLog(yesterdayLog);

        int todayEmissions = 0;
        final subscription = repo
            .watchWorkLogsByDateRange(today, today.add(Duration(days: 1)))
            .listen((_) {
          todayEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        todayEmissions = 0;

        // Update yesterday's log (outside range)
        await repo.upsertWorkLog(yesterdayLog.copyWith(count: 15));
        await Future.delayed(Duration(milliseconds: 50));

        expect(todayEmissions, equals(0));

        // Update today's log
        await repo.upsertWorkLog(todayLog.copyWith(count: 7));
        await Future.delayed(Duration(milliseconds: 50));

        expect(todayEmissions, equals(1));

        subscription.cancel();
      });

      test('watchWorkLogsByUser() emits only when user logs change', () async {
        final userALog = LogEntry(
          id: 'log-a',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
          user: 'user-a',
          date: DateTime.now(),
        );
        final userBLog = LogEntry(
          id: 'log-b',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          date: DateTime.now(),
        );

        await repo.upsertWorkLog(userALog);
        await repo.upsertWorkLog(userBLog);

        int userAEmissions = 0;
        final subscription = repo.watchWorkLogsByUser('user-a').listen((_) {
          userAEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        userAEmissions = 0;

        // Update user-b log
        await repo.upsertWorkLog(userBLog.copyWith(count: 15));
        await Future.delayed(Duration(milliseconds: 50));

        expect(userAEmissions, equals(0));

        subscription.cancel();
      });

      test('watchWorkLogsByItem() emits only when item logs change', () async {
        final item1Log = LogEntry(
          id: 'log-1',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
          user: 'user-a',
          date: DateTime.now(),
        );
        final item2Log = LogEntry(
          id: 'log-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          date: DateTime.now(),
        );

        await repo.upsertWorkLog(item1Log);
        await repo.upsertWorkLog(item2Log);

        int item1Emissions = 0;
        final subscription = repo.watchWorkLogsByItem('item-1').listen((_) {
          item1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        item1Emissions = 0;

        // Update item-2 log
        await repo.upsertWorkLog(item2Log.copyWith(count: 15));
        await Future.delayed(Duration(milliseconds: 50));

        expect(item1Emissions, equals(0));

        subscription.cancel();
      });

      test('watchWorkLogsByContainer() emits only when container logs change', () async {
        final container1Log = LogEntry(
          id: 'log-1',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
          user: 'user-a',
          date: DateTime.now(),
        );
        final container2Log = LogEntry(
          id: 'log-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          date: DateTime.now(),
        );

        await repo.upsertWorkLog(container1Log);
        await repo.upsertWorkLog(container2Log);

        int container1Emissions = 0;
        final subscription = repo.watchWorkLogsByContainer('container-1').listen((_) {
          container1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        container1Emissions = 0;

        // Update container-2 log
        await repo.upsertWorkLog(container2Log.copyWith(count: 15));
        await Future.delayed(Duration(milliseconds: 50));

        expect(container1Emissions, equals(0));

        subscription.cancel();
      });
    });
  });
}
