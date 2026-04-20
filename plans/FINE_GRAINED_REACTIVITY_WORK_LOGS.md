# Fine-Grained Reactivity: Work Logs Repository

## Objective
Optimize work log queries for audit trail and reporting use cases. Work logs are write-heavy (created on every assignment change) but read-light (only viewed in audit pages). Currently, the work log page watches ALL logs, which is inefficient for large datasets.

## Expected Impact
- **Current:** Work log page loads ALL logs, slows down with thousands of entries
- **Target:** Work log page loads only relevant subset (by date, user, or entity)
- **Estimated rebuild reduction:** 60-75%
- **Query performance:** 5-10x faster for filtered views

## Priority: MEDIUM-LOW
Work logs are mostly background data. Users don't interact with them frequently, but when they do (audit reports), performance matters.

---

## Step 1: Write Phase 1 Tests (Repository Stream Efficiency)

**Estimated Time:** 1 hour

### 1.1 Create Test File

**File:** `test/repositories/work_log_repository_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_work_log_repository.dart';
import '../helpers/test_helpers.dart';

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
          timestamp: DateTime.now(),
        );
        final log2 = LogEntry(
          id: 'log-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          timestamp: DateTime.now(),
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
          timestamp: today,
        );
        final yesterdayLog = LogEntry(
          id: 'log-yesterday',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          timestamp: yesterday,
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
          timestamp: DateTime.now(),
        );
        final userBLog = LogEntry(
          id: 'log-b',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          timestamp: DateTime.now(),
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
          timestamp: DateTime.now(),
        );
        final item2Log = LogEntry(
          id: 'log-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
          user: 'user-b',
          timestamp: DateTime.now(),
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
    });
  });
}
```

### 1.2 Run Tests (Should FAIL)

```bash
flutter test test/repositories/work_log_repository_rebuild_test.dart
```

---

## Step 2: Update Repository Interface

**Estimated Time:** 20 minutes

### 2.1 Update Work Log Repository Interface

**File:** `lib/repositories/work_log_repository.dart`

Add these methods:

```dart
abstract class WorkLogRepository {
  // Existing methods...
  Stream<List<LogEntry>> watchWorkLogs();
  Future<List<LogEntry>> getWorkLogsSince(DateTime since);
  Future<void> upsertWorkLog(LogEntry logEntry);
  Future<void> deleteWorkLog(String id);
  Future<void> batchUpsertWorkLogs(List<LogEntry> logEntries);

  // NEW: Fine-grained stream methods

  /// Watch work logs within a date range.
  /// Emits only when logs within this range change.
  /// Useful for daily/weekly audit reports.
  Stream<List<LogEntry>> watchWorkLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Watch work logs by a specific user.
  /// Emits only when logs for this user change.
  Stream<List<LogEntry>> watchWorkLogsByUser(String userId);

  /// Watch work logs for a specific item.
  /// Emits only when logs for this item change.
  Stream<List<LogEntry>> watchWorkLogsByItem(String itemId);

  /// Watch work logs for a specific container.
  /// Emits only when logs for this container change.
  Stream<List<LogEntry>> watchWorkLogsByContainer(String containerId);
}
```

---

## Step 3: Implement Firebase Repository

**Estimated Time:** 1.5 hours

### 3.1 Update Firebase Work Log Repository

**File:** `lib/repositories/impl/firebase/firebase_work_log_repository.dart`

Add implementations:

```dart
@override
Stream<List<LogEntry>> watchWorkLogsByDateRange(
  DateTime startDate,
  DateTime endDate,
) {
  return workLogCollection
      .where('timestamp', isGreaterThanOrEqualTo: startDate)
      .where('timestamp', isLessThan: endDate)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<List<LogEntry>> watchWorkLogsByUser(String userId) {
  return workLogCollection
      .where('user', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<List<LogEntry>> watchWorkLogsByItem(String itemId) {
  return workLogCollection
      .where('itemId', isEqualTo: itemId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<List<LogEntry>> watchWorkLogsByContainer(String containerId) {
  return workLogCollection
      .where('containerId', isEqualTo: containerId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}
```

**Note:** These queries require Firestore composite indexes. Firebase will prompt you to create them on first use.

**Required Indexes:**
- `work_log`: `timestamp ASC, __name__ ASC`
- `work_log`: `user ASC, timestamp DESC`
- `work_log`: `itemId ASC, timestamp DESC`
- `work_log`: `containerId ASC, timestamp DESC`

---

## Step 4: Implement Mock Repository

**Estimated Time:** 45 minutes

### 4.1 Update Mock Work Log Repository

**File:** `lib/repositories/impl/mock/mock_work_log_repository.dart`

Add implementations:

```dart
@override
Stream<List<LogEntry>> watchWorkLogsByDateRange(
  DateTime startDate,
  DateTime endDate,
) {
  return _workLogsController.stream.map(
    (allLogs) => allLogs
        .where((log) =>
            log.timestamp.isAfter(startDate) &&
            log.timestamp.isBefore(endDate))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
  );
}

@override
Stream<List<LogEntry>> watchWorkLogsByUser(String userId) {
  return _workLogsController.stream.map(
    (allLogs) => allLogs.where((log) => log.user == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
  );
}

@override
Stream<List<LogEntry>> watchWorkLogsByItem(String itemId) {
  return _workLogsController.stream.map(
    (allLogs) => allLogs.where((log) => log.itemId == itemId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
  );
}

@override
Stream<List<LogEntry>> watchWorkLogsByContainer(String containerId) {
  return _workLogsController.stream.map(
    (allLogs) => allLogs.where((log) => log.containerId == containerId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
  );
}
```

### 4.2 Add clearLogs() and dispose() if missing

```dart
void clearLogs() {
  _workLogs.clear();
  _workLogsController.add([]);
}

void dispose() {
  _workLogsController.close();
}
```

---

## Step 5: Verify Phase 1 Tests Pass

**Estimated Time:** 20 minutes

```bash
flutter test test/repositories/work_log_repository_rebuild_test.dart
```

---

## Step 6: Write Phase 2 Tests (Provider Rebuild Efficiency)

**Estimated Time:** 1 hour

### 6.1 Create Provider Test File

**File:** `test/state/work_log_provider_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/work_logs_by_date_range_notifier.dart';
import 'package:rescuenet_warehouse/state/work_logs_by_user_notifier.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Work Log Provider Rebuild Efficiency', () {
    test('workLogsByDateRangeProvider only rebuilds when logs in range change',
        () async {
      final container = createTestProviderContainer();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(Duration(days: 1));

      final todayLog = LogEntry(
        id: 'log-today',
        itemId: 'item-1',
        containerId: 'container-1',
        count: 5,
        user: 'user-a',
        timestamp: today,
      );
      final yesterdayLog = LogEntry(
        id: 'log-yesterday',
        itemId: 'item-2',
        containerId: 'container-2',
        count: 10,
        user: 'user-b',
        timestamp: yesterday,
      );

      final repo = container.read(workLogRepositoryProvider);
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

      // Update yesterday's log
      await repo.upsertWorkLog(yesterdayLog.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 100));

      expect(todayRebuilds, equals(0));

      container.dispose();
    });

    test('workLogsByUserProvider only rebuilds when user logs change',
        () async {
      final container = createTestProviderContainer();

      final userALog = LogEntry(
        id: 'log-a',
        itemId: 'item-1',
        containerId: 'container-1',
        count: 5,
        user: 'user-a',
        timestamp: DateTime.now(),
      );
      final userBLog = LogEntry(
        id: 'log-b',
        itemId: 'item-2',
        containerId: 'container-2',
        count: 10,
        user: 'user-b',
        timestamp: DateTime.now(),
      );

      final repo = container.read(workLogRepositoryProvider);
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

      container.dispose();
    });
  });
}
```

---

## Step 7: Create Family Providers

**Estimated Time:** 1 hour

### 7.1 Create WorkLogsByDateRange Provider

**File:** `lib/state/work_logs_by_date_range_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'work_logs_by_date_range_notifier.g.dart';

/// Watches work logs within a specific date range.
/// Only rebuilds when logs within THIS range change.
///
/// Useful for daily/weekly audit reports.
///
/// Usage:
/// ```dart
/// final todayLogs = ref.watch(workLogsByDateRangeProvider(
///   DateTime.now(),
///   DateTime.now().add(Duration(days: 1)),
/// ));
/// ```
@riverpod
class WorkLogsByDateRange extends _$WorkLogsByDateRange {
  @override
  Stream<List<LogEntry>> build(DateTime startDate, DateTime endDate) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByDateRange(startDate, endDate);
  }

  /// Get count of logs in this date range
  int get count => state.valueOrNull?.length ?? 0;
}
```

### 7.2 Create WorkLogsByUser Provider

**File:** `lib/state/work_logs_by_user_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'work_logs_by_user_notifier.g.dart';

/// Watches work logs for a specific user.
/// Only rebuilds when logs for THIS user change.
///
/// Usage:
/// ```dart
/// final userLogs = ref.watch(workLogsByUserProvider(userId));
/// ```
@riverpod
class WorkLogsByUser extends _$WorkLogsByUser {
  @override
  Stream<List<LogEntry>> build(String userId) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByUser(userId);
  }
}
```

### 7.3 Create WorkLogsByItem Provider

**File:** `lib/state/work_logs_by_item_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'work_logs_by_item_notifier.g.dart';

/// Watches work logs for a specific item.
/// Only rebuilds when logs for THIS item change.
///
/// Useful for item history/audit trail.
///
/// Usage:
/// ```dart
/// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
/// ```
@riverpod
class WorkLogsByItem extends _$WorkLogsByItem {
  @override
  Stream<List<LogEntry>> build(String itemId) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByItem(itemId);
  }
}
```

### 7.4 Create WorkLogsByContainer Provider

**File:** `lib/state/work_logs_by_container_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'work_logs_by_container_notifier.g.dart';

/// Watches work logs for a specific container.
/// Only rebuilds when logs for THIS container change.
///
/// Useful for container history/audit trail.
///
/// Usage:
/// ```dart
/// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
/// ```
@riverpod
class WorkLogsByContainer extends _$WorkLogsByContainer {
  @override
  Stream<List<LogEntry>> build(String containerId) {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogsByContainer(containerId);
  }
}
```

---

## Step 8: Run Code Generation

**Estimated Time:** 2 minutes

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 9: Verify Phase 2 Tests Pass

**Estimated Time:** 20 minutes

```bash
flutter test test/state/work_log_provider_rebuild_test.dart
```

---

## Step 10: Migrate Widgets

**Estimated Time:** 1 hour

### 10.1 Find Widgets to Migrate

```bash
grep -r "ref.watch(allWorkLogsAsyncProvider)" lib/ui/ lib/features/
grep -r "ref.watch(workLogNotifierProvider)" lib/ui/ lib/features/
```

### 10.2 Migration Patterns

#### Pattern 1: Daily Work Log View

**Before:**
```dart
final allLogs = ref.watch(allWorkLogsAsyncProvider);
final todayLogs = allLogs.valueOrNull
    ?.where((log) => log.timestamp.isAfter(DateTime.now().subtract(Duration(days: 1))))
    .toList();
```

**After:**
```dart
final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);
final todayLogs = ref.watch(
  workLogsByDateRangeProvider(today, today.add(Duration(days: 1))),
);
```

#### Pattern 2: User Activity Log

**Before:**
```dart
final allLogs = ref.watch(allWorkLogsAsyncProvider);
final userLogs = allLogs.valueOrNull
    ?.where((log) => log.user == currentUser)
    .toList();
```

**After:**
```dart
final userLogs = ref.watch(workLogsByUserProvider(currentUser));
```

#### Pattern 3: Item/Container History

**Before:**
```dart
final allLogs = ref.watch(allWorkLogsAsyncProvider);
final itemHistory = allLogs.valueOrNull
    ?.where((log) => log.itemId == itemId)
    .toList();
```

**After:**
```dart
final itemHistory = ref.watch(workLogsByItemProvider(itemId));
```

### 10.3 Key Files to Update

1. **WorkLogPage** (`lib/ui/work_log_page/work_log_page.dart`)
   - Currently uses `workLogNotifierProvider` with date filter
   - Change to: `workLogsByDateRangeProvider(startDate, endDate)`

2. **WorkLogSinceNotifier** (`lib/state/work_log_since_notifier.dart`)
   - Uses `allWorkLogsAsyncProvider` with manual filtering
   - Replace with: `workLogsByDateRangeProvider`

3. **Item/Container Detail Pages** (if showing history)
   - Use `workLogsByItemProvider` or `workLogsByContainerProvider`

### 10.4 Keep Collection Provider For

- Admin views showing ALL logs
- Export/backup features
- Full audit trail reports

**Note:** Most work log views are already filtered by date. This migration will have immediate performance benefits.

---

## Step 11: Manual Testing

**Estimated Time:** 20 minutes

### 11.1 Work Log Page Performance

1. Create 100+ work log entries
2. Filter to today's logs
3. **Verify:** Fast load, no lag
4. Add new log entry
5. **Verify:** Only today's view updates

### 11.2 Item History

1. View item history
2. Create assignment (creates work log)
3. **Verify:** Item history updates instantly

---

## Step 12: Create Firestore Indexes

**Estimated Time:** 10 minutes

After deploying, Firebase will show console errors for missing indexes. Click the provided links to auto-create them, or manually create:

**firestore.indexes.json:**
```json
{
  "indexes": [
    {
      "collectionGroup": "work_log",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "timestamp", "order": "ASCENDING" },
        { "fieldPath": "__name__", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "work_log",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "user", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "work_log",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "itemId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "work_log",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "containerId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ]
}
```

Deploy indexes:
```bash
firebase deploy --only firestore:indexes
```

---

## Success Criteria

- ✅ All Phase 1 tests pass
- ✅ All Phase 2 tests pass
- ✅ Work log page loads <1s with 1000+ entries
- ✅ Firestore indexes created successfully
- ✅ Date range filtering works correctly

---

## Performance Benefits

### Before:
- Work log page with 1000 entries: 3-5s load time
- Query fetches ALL logs, filters client-side
- Every new log triggers full collection re-render

### After:
- Work log page with 1000 entries: <1s load time
- Query fetches only date range (typically 10-50 logs)
- New logs only update relevant date range views

---

## Special Considerations

### Firestore Composite Indexes

Work logs require composite indexes for efficient querying. These are automatically suggested by Firebase but must be created before queries work.

**Index Creation Options:**
1. Click Firebase Console error links (easiest)
2. Use `firestore.indexes.json` (shown above)
3. Manually create in Firebase Console

### Date Range Queries

When using date ranges, ensure dates are normalized:
```dart
// Good: Normalized to day boundaries
final today = DateTime(now.year, now.month, now.day);
final tomorrow = today.add(Duration(days: 1));

// Bad: Includes time component
final today = DateTime.now(); // May miss logs after current time
```

---

## Notes

- Work logs are append-only (rarely deleted)
- Date range queries are most common use case
- User queries useful for activity tracking
- Item/Container queries useful for audit trails
- Keep collection provider for full exports only
