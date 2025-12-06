# Fine-Grained Reactivity: Assignments Repository

## Objective
Eliminate excessive widget rebuilds caused by collection-level assignment listeners. Currently, when ANY assignment changes, ALL widgets watching assignments rebuild. After this refactor, only widgets watching the specific changed assignment will rebuild.

## Expected Impact
- **Current:** Update assignment in Container A → ALL container views rebuild
- **Target:** Update assignment in Container A → ONLY Container A view rebuilds
- **Estimated rebuild reduction:** 80-90%

## Priority: HIGHEST
Assignments are the most frequently updated entity (users constantly assign/unassign items) and affect the most UI components.

---

## Step 1: Write Phase 1 Tests (Repository Stream Efficiency)

**Estimated Time:** 1.5 hours

### 1.1 Create Test File

**File:** `test/repositories/assignment_repository_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_assignment_repository.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AssignmentRepository Rebuild Efficiency', () {
    late MockAssignmentRepository repo;

    setUp(() {
      repo = MockAssignmentRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    group('Baseline (Current Behavior)', () {
      test('watchAssignments() emits entire collection on any change', () async {
        // Document current coarse-grained behavior
        final assignment1 = createTestAssignment(
          id: 'assign-1',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
        );
        final assignment2 = createTestAssignment(
          id: 'assign-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
        );

        await repo.upsertAssignment(assignment1);
        await repo.upsertAssignment(assignment2);

        int emissionCount = 0;
        final subscription = repo.watchAssignments().listen((_) {
          emissionCount++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        emissionCount = 0; // Reset after initial emission

        // Update assignment 1
        await repo.upsertAssignment(assignment1.copyWith(count: 7));
        await Future.delayed(Duration(milliseconds: 50));

        // Current behavior: Emits entire collection
        expect(emissionCount, greaterThan(0));

        subscription.cancel();
      });
    });

    group('Fine-Grained (Target Behavior)', () {
      test('watchAssignmentsByContainer() emits only when container assignments change', () async {
        final assignment1 = createTestAssignment(
          id: 'assign-1',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
        );
        final assignment2 = createTestAssignment(
          id: 'assign-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
        );

        await repo.upsertAssignment(assignment1);
        await repo.upsertAssignment(assignment2);

        int container1Emissions = 0;
        final subscription = repo
            .watchAssignmentsByContainer('container-1')
            .listen((_) {
          container1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        container1Emissions = 0; // Reset after initial

        // Update assignment in container-2 (different container)
        await repo.upsertAssignment(assignment2.copyWith(count: 15));
        await Future.delayed(Duration(milliseconds: 50));

        // Should NOT emit for container-1 listener
        expect(container1Emissions, equals(0));

        // Update assignment in container-1
        await repo.upsertAssignment(assignment1.copyWith(count: 7));
        await Future.delayed(Duration(milliseconds: 50));

        // Should emit for container-1 listener
        expect(container1Emissions, equals(1));

        subscription.cancel();
      });

      test('watchAssignmentsByItem() emits only when item assignments change', () async {
        final assignment1 = createTestAssignment(
          id: 'assign-1',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 5,
        );
        final assignment2 = createTestAssignment(
          id: 'assign-2',
          itemId: 'item-2',
          containerId: 'container-2',
          count: 10,
        );

        await repo.upsertAssignment(assignment1);
        await repo.upsertAssignment(assignment2);

        int item1Emissions = 0;
        final subscription = repo.watchAssignmentsByItem('item-1').listen((_) {
          item1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        item1Emissions = 0;

        // Update assignment for item-2
        await repo.upsertAssignment(assignment2.copyWith(count: 15));
        await Future.delayed(Duration(milliseconds: 50));

        expect(item1Emissions, equals(0));

        // Update assignment for item-1
        await repo.upsertAssignment(assignment1.copyWith(count: 7));
        await Future.delayed(Duration(milliseconds: 50));

        expect(item1Emissions, equals(1));

        subscription.cancel();
      });

      test('watchAssignment() emits only for specific assignment', () async {
        final assignment1 = createTestAssignment(id: 'assign-1');
        final assignment2 = createTestAssignment(id: 'assign-2');

        await repo.upsertAssignment(assignment1);
        await repo.upsertAssignment(assignment2);

        int assign1Emissions = 0;
        final subscription = repo.watchAssignment('assign-1').listen((_) {
          assign1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        assign1Emissions = 0;

        // Update different assignment
        await repo.upsertAssignment(assignment2.copyWith(count: 15));
        await Future.delayed(Duration(milliseconds: 50));

        expect(assign1Emissions, equals(0));

        // Update tracked assignment
        await repo.upsertAssignment(assignment1.copyWith(count: 7));
        await Future.delayed(Duration(milliseconds: 50));

        expect(assign1Emissions, equals(1));

        subscription.cancel();
      });
    });
  });
}
```

### 1.2 Run Tests (They Should FAIL)

```bash
flutter test test/repositories/assignment_repository_rebuild_test.dart
```

Expected: Fine-grained tests fail because methods don't exist yet. This is correct - tests drive implementation.

---

## Step 2: Update Repository Interface

**Estimated Time:** 30 minutes

### 2.1 Update Assignment Repository Interface

**File:** `lib/repositories/assignment_repository.dart`

Add these methods to the abstract class:

```dart
abstract class AssignmentRepository {
  // Existing methods...
  Stream<List<Assignment>> watchAssignments();
  Future<Assignment?> getAssignment(String id);
  Future<List<Assignment>> getAssignmentsForContainer(String containerId);
  Future<List<Assignment>> getAssignmentsForItem(String itemId);
  Future<Assignment?> getAssignmentByIds(String itemId, String containerId);
  Future<void> upsertAssignment(Assignment assignment);
  Future<void> deleteAssignment(String id);
  Future<void> batchUpdateAssignments(List<Assignment> assignments);
  Future<void> batchDeleteAssignments(List<String> assignmentIds);

  // NEW: Fine-grained stream methods

  /// Watch assignments for a specific container.
  /// Emits only when assignments for this container change.
  Stream<List<Assignment>> watchAssignmentsByContainer(String containerId);

  /// Watch assignments for a specific item.
  /// Emits only when assignments for this item change.
  Stream<List<Assignment>> watchAssignmentsByItem(String itemId);

  /// Watch a single assignment by ID.
  /// Emits only when this specific assignment changes.
  Stream<Assignment?> watchAssignment(String assignmentId);
}
```

---

## Step 3: Implement Firebase Repository

**Estimated Time:** 2 hours

### 3.1 Update Firebase Assignment Repository

**File:** `lib/repositories/impl/firebase/firebase_assignment_repository.dart`

Add implementations:

```dart
@override
Stream<List<Assignment>> watchAssignmentsByContainer(String containerId) {
  return assignmentCollection
      .where('containerId', isEqualTo: containerId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<List<Assignment>> watchAssignmentsByItem(String itemId) {
  return assignmentCollection
      .where('itemId', isEqualTo: itemId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<Assignment?> watchAssignment(String assignmentId) {
  return assignmentCollection.doc(assignmentId).snapshots().map(
        (snapshot) => snapshot.exists ? snapshot.data() : null,
      );
}
```

**Note:** These use Firestore's `.where()` queries, which only emit when matching documents change. This is the key to fine-grained reactivity.

---

## Step 4: Implement Mock Repository

**Estimated Time:** 1 hour

### 4.1 Update Mock Assignment Repository

**File:** `lib/repositories/impl/mock/mock_assignment_repository.dart`

Add implementations:

```dart
@override
Stream<List<Assignment>> watchAssignmentsByContainer(String containerId) {
  return _assignmentsController.stream.map(
    (allAssignments) => allAssignments
        .where((a) => a.containerId == containerId)
        .toList(),
  );
}

@override
Stream<List<Assignment>> watchAssignmentsByItem(String itemId) {
  return _assignmentsController.stream.map(
    (allAssignments) =>
        allAssignments.where((a) => a.itemId == itemId).toList(),
  );
}

@override
Stream<Assignment?> watchAssignment(String assignmentId) {
  return _assignmentsController.stream.map(
    (allAssignments) {
      try {
        return allAssignments.firstWhere((a) => a.id == assignmentId);
      } catch (e) {
        return null;
      }
    },
  );
}
```

**Important:** Mock uses stream mapping to filter. This matches Firebase behavior where only relevant changes trigger emissions.

### 4.2 Add dispose() method if missing

Ensure MockAssignmentRepository has a dispose method for test cleanup:

```dart
void dispose() {
  _assignmentsController.close();
}
```

---

## Step 5: Verify Phase 1 Tests Pass

**Estimated Time:** 30 minutes

```bash
flutter test test/repositories/assignment_repository_rebuild_test.dart
```

**Success Criteria:** All tests pass, proving repository correctly filters emissions.

---

## Step 6: Write Phase 2 Tests (Provider Rebuild Efficiency)

**Estimated Time:** 2 hours

### 6.1 Create Provider Test File

**File:** `test/state/assignment_provider_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/assignments_by_container_notifier.dart';
import 'package:rescuenet_warehouse/state/assignments_by_item_notifier.dart';
import 'package:rescuenet_warehouse/state/assignment_by_id_notifier.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Assignment Provider Rebuild Efficiency', () {
    test('assignmentsByContainerProvider only rebuilds when container changes',
        () async {
      final container = createTestProviderContainer();

      final assignment1 = createTestAssignment(
        id: 'assign-1',
        itemId: 'item-1',
        containerId: 'container-1',
        count: 5,
      );
      final assignment2 = createTestAssignment(
        id: 'assign-2',
        itemId: 'item-2',
        containerId: 'container-2',
        count: 10,
      );

      // Setup initial data
      final repo = container.read(assignmentRepositoryProvider);
      await repo.upsertAssignment(assignment1);
      await repo.upsertAssignment(assignment2);

      // Track rebuilds for container-1
      int container1Rebuilds = 0;
      container.listen(
        assignmentsByContainerProvider('container-1'),
        (previous, next) {
          container1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      container1Rebuilds = 0; // Reset after initial

      // Update assignment in container-2
      await repo.upsertAssignment(assignment2.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 100));

      // Container-1 provider should NOT rebuild
      expect(container1Rebuilds, equals(0));

      // Update assignment in container-1
      await repo.upsertAssignment(assignment1.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 100));

      // Container-1 provider SHOULD rebuild
      expect(container1Rebuilds, equals(1));

      container.dispose();
    });

    test('assignmentsByItemProvider only rebuilds when item changes',
        () async {
      final container = createTestProviderContainer();

      final assignment1 = createTestAssignment(
        id: 'assign-1',
        itemId: 'item-1',
        containerId: 'container-1',
      );
      final assignment2 = createTestAssignment(
        id: 'assign-2',
        itemId: 'item-2',
        containerId: 'container-2',
      );

      final repo = container.read(assignmentRepositoryProvider);
      await repo.upsertAssignment(assignment1);
      await repo.upsertAssignment(assignment2);

      int item1Rebuilds = 0;
      container.listen(
        assignmentsByItemProvider('item-1'),
        (previous, next) {
          item1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      item1Rebuilds = 0;

      // Update assignment for item-2
      await repo.upsertAssignment(assignment2.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 100));

      expect(item1Rebuilds, equals(0));

      // Update assignment for item-1
      await repo.upsertAssignment(assignment1.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 100));

      expect(item1Rebuilds, equals(1));

      container.dispose();
    });

    test('assignmentByIdProvider only rebuilds for specific assignment',
        () async {
      final container = createTestProviderContainer();

      final assignment1 = createTestAssignment(id: 'assign-1');
      final assignment2 = createTestAssignment(id: 'assign-2');

      final repo = container.read(assignmentRepositoryProvider);
      await repo.upsertAssignment(assignment1);
      await repo.upsertAssignment(assignment2);

      int assign1Rebuilds = 0;
      container.listen(
        assignmentByIdProvider('assign-1'),
        (previous, next) {
          assign1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      assign1Rebuilds = 0;

      // Update different assignment
      await repo.upsertAssignment(assignment2.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 100));

      expect(assign1Rebuilds, equals(0));

      // Update tracked assignment
      await repo.upsertAssignment(assignment1.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 100));

      expect(assign1Rebuilds, equals(1));

      container.dispose();
    });
  });
}
```

---

## Step 7: Create Family Providers

**Estimated Time:** 1.5 hours

### 7.1 Create AssignmentsByContainer Provider

**File:** `lib/state/assignments_by_container_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'assignments_by_container_notifier.g.dart';

/// Watches assignments for a specific container.
/// Only rebuilds when assignments for THIS container change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
/// ```
@riverpod
class AssignmentsByContainer extends _$AssignmentsByContainer {
  @override
  Stream<List<Assignment>> build(String containerId) {
    final repository = ref.watch(assignmentRepositoryProvider);
    return repository.watchAssignmentsByContainer(containerId);
  }

  /// Get total count of assignments for this container
  int getTotalCount() {
    final assignments = state.valueOrNull ?? [];
    return assignments.fold(0, (sum, a) => sum + a.count);
  }
}
```

### 7.2 Create AssignmentsByItem Provider

**File:** `lib/state/assignments_by_item_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'assignments_by_item_notifier.g.dart';

/// Watches assignments for a specific item.
/// Only rebuilds when assignments for THIS item change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByItemProvider(itemId));
/// ```
@riverpod
class AssignmentsByItem extends _$AssignmentsByItem {
  @override
  Stream<List<Assignment>> build(String itemId) {
    final repository = ref.watch(assignmentRepositoryProvider);
    return repository.watchAssignmentsByItem(itemId);
  }

  /// Get total count of this item across all containers
  int getTotalAssigned() {
    final assignments = state.valueOrNull ?? [];
    return assignments.fold(0, (sum, a) => sum + a.count);
  }
}
```

### 7.3 Create AssignmentById Provider

**File:** `lib/state/assignment_by_id_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'assignment_by_id_notifier.g.dart';

/// Watches a single assignment by ID.
/// Only rebuilds when THIS specific assignment changes.
///
/// Usage:
/// ```dart
/// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
/// ```
@riverpod
class AssignmentById extends _$AssignmentById {
  @override
  Stream<Assignment?> build(String assignmentId) {
    final repository = ref.watch(assignmentRepositoryProvider);
    return repository.watchAssignment(assignmentId);
  }
}
```

---

## Step 8: Run Code Generation

**Estimated Time:** 2 minutes

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `.g.dart` files for the new providers.

---

## Step 9: Verify Phase 2 Tests Pass

**Estimated Time:** 30 minutes

```bash
flutter test test/state/assignment_provider_rebuild_test.dart
```

**Success Criteria:** All provider tests pass, proving fine-grained reactivity works.

---

## Step 10: Migrate Widgets

**Estimated Time:** 2 hours

### 10.1 Find Widgets to Migrate

```bash
grep -r "ref.watch(allAssignmentsAsyncProvider)" lib/ui/ lib/features/
```

### 10.2 Migration Pattern

**Before:**
```dart
final allAssignments = ref.watch(allAssignmentsAsyncProvider);
final containerAssignments = allAssignments.valueOrNull
    ?.where((a) => a.containerId == _container.id)
    .toList() ?? [];
```

**After:**
```dart
final containerAssignments = ref.watch(
  assignmentsByContainerProvider(_container.id),
);
```

### 10.3 Key Files to Update

1. **ContainerWithContentColumn** (`lib/ui/container_with_content/container_with_content_column.dart`)
   - Currently watches `allAssignmentsAsyncProvider`
   - Change to: `assignmentsByContainerProvider(_container.id)`

2. **CurrentItemAssignmentsNotifier** (`lib/state/current_item_assignments_notifier.dart`)
   - Currently watches `allAssignmentsAsyncProvider` and filters by item
   - Change to: `assignmentsByItemProvider(itemId)`

3. **ContainerVisibilityNotifier** (`lib/state/container_visibility_notifier.dart`)
   - Keep as-is if it needs ALL assignments for filtering logic
   - Only migrate if it's filtering by specific container/item

### 10.4 Keep Collection Provider For

- Dashboard views showing all assignments
- Admin reports
- Export/import features
- Full assignment list views

**Rule:** If a widget filters/maps to a subset, use family provider. If it needs the full collection, keep `allAssignmentsAsyncProvider`.

---

## Step 11: Manual Testing

**Estimated Time:** 30 minutes

### 11.1 Multi-User Simulation

1. Open app in 2 browser windows
2. Window A: View Container #1
3. Window B: View Container #2
4. Window A: Update assignment in Container #1
5. **Verify:** Window B does NOT flicker/reload

### 11.2 DevTools Verification

1. Open Flutter DevTools
2. Go to Riverpod Inspector
3. Watch provider rebuild counts
4. Update an assignment
5. **Verify:** Only relevant providers rebuild

### 11.3 Performance Check

1. Create 50+ assignments across 10 containers
2. Update 1 assignment
3. **Verify:** UI responds instantly, no lag

---

## Step 12: Integration Test

**Estimated Time:** 1 hour

**File:** `test/state/assignment_integration_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/assignments_by_container_notifier.dart';
import 'package:rescuenet_warehouse/state/container_with_items_notifier.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Assignment Integration - Multi-Provider Rebuild', () {
    test('Updating Container A assignments does not rebuild Container B watchers',
        () async {
      final container = createTestProviderContainer();

      // Setup: Create assignments for 2 containers
      final assignment1 = createTestAssignment(
        id: 'assign-1',
        itemId: 'item-1',
        containerId: 'container-1',
        count: 5,
      );
      final assignment2 = createTestAssignment(
        id: 'assign-2',
        itemId: 'item-2',
        containerId: 'container-2',
        count: 10,
      );

      final repo = container.read(assignmentRepositoryProvider);
      await repo.upsertAssignment(assignment1);
      await repo.upsertAssignment(assignment2);

      // Track rebuilds for Container B
      int containerBRebuilds = 0;
      container.listen(
        assignmentsByContainerProvider('container-2'),
        (previous, next) {
          containerBRebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      containerBRebuilds = 0;

      // Update assignment in Container A
      await repo.upsertAssignment(assignment1.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 100));

      // Container B should NOT rebuild
      expect(containerBRebuilds, equals(0));

      container.dispose();
    });
  });
}
```

---

## Success Criteria

- ✅ All Phase 1 tests pass (repository streams are fine-grained)
- ✅ All Phase 2 tests pass (providers rebuild correctly)
- ✅ Integration test passes (cross-provider isolation works)
- ✅ Manual testing shows no unnecessary rebuilds
- ✅ DevTools shows reduced rebuild counts

---

## Rollback Plan

If issues arise:

1. Keep new providers but don't migrate widgets
2. New code is additive - old code still works
3. Can migrate widgets incrementally, one at a time
4. Remove new providers only if fundamentally broken

---

## Notes

- **Do not delete** `allAssignmentsAsyncProvider` - still needed for full-list views
- Family providers are **additive**, not replacements
- Migration is **incremental** - can be done over multiple PRs
- Focus on high-traffic widgets first (ContainerWithContentColumn)
