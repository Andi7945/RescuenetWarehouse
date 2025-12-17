import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_logs_by_date_range_notifier.dart';
import 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_logs_by_user_notifier.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/features/worklog/providers/work_log_providers.dart';
import 'package:rescuenet_warehouse/features/worklog/repository/mock_work_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Helper to create test provider container with shared repository
ProviderContainer createTestProviderContainer(MockWorkLogRepository repo) {
  return ProviderContainer(
    overrides: [
      workLogRepositoryProvider.overrideWith((ref) => repo),
    ],
  );
}

void main() {
  group('Work Log Provider Rebuild Efficiency', () {
    test('workLogsByDateRangeProvider only rebuilds when logs in range change',
        () async {
      final repo = MockWorkLogRepository();
      repo.clearLogs();
      final container = createTestProviderContainer(repo);

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

      int todayRebuilds = 0;
      container.listen(
        workLogsByDateRangeProvider(today, today.add(Duration(days: 1))),
        (previous, next) {
          todayRebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      todayRebuilds = 0;

      // Update yesterday's log (outside range)
      await repo.upsertWorkLog(yesterdayLog.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 100));

      expect(todayRebuilds, equals(0));

      // Update today's log (inside range)
      await repo.upsertWorkLog(todayLog.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 100));

      expect(todayRebuilds, equals(1));

      repo.dispose();
      container.dispose();
    });

    test('workLogsByUserProvider only rebuilds when user logs change',
        () async {
      final repo = MockWorkLogRepository();
      repo.clearLogs();
      final container = createTestProviderContainer(repo);

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

      int userARebuilds = 0;
      container.listen(
        workLogsByUserProvider('user-a'),
        (previous, next) {
          userARebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      userARebuilds = 0;

      // Update user-b log
      await repo.upsertWorkLog(userBLog.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 100));

      expect(userARebuilds, equals(0));

      // Update user-a log
      await repo.upsertWorkLog(userALog.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 100));

      expect(userARebuilds, equals(1));

      repo.dispose();
      container.dispose();
    });
  });
}
