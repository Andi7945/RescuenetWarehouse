# Refactor Assignment Feature: Extract Service Layer

## Overview

This plan refactors the assignment feature to improve separation of concerns between business logic and presentation logic. The main goal is to extract business logic into pure functions and a dedicated service layer, making the code more modular, testable, and maintainable.

**Current Problems:**
- Business logic scattered across state notifiers, repositories, and UI components
- Work log creation coupled with every assignment operation
- Difficult to test business rules (requires mocking multiple repositories)
- Duplicate orchestration logic in multiple places
- Repository layer contains business logic (count == 0 deletion rule)

**Solution:**
- Extract pure business rules into testable functions
- Create `AssignmentService` to orchestrate workflows (assignments + work logs)
- Simplify state notifiers to delegate to service
- Clean up repository to be pure data access
- Update UI components to use services

**Principles:**
- **SRP**: Each layer has one clear responsibility
- **KISS**: Simple, focused functions and classes
- **Modularity**: Reusable pure functions, injectable services
- **Testing**: Test business logic with pure functions (no mocking needed)

---

## Prerequisites

Before starting:
- ✅ All existing tests pass
- ✅ Understanding of current assignment flow (read analysis in this file)
- ✅ Git branch created for this refactoring

---

## Implementation Phases

### Phase 1: Foundation - Pure Business Rules (No Breaking Changes)

**Goal:** Extract business logic into pure, testable functions without changing existing behavior.

**Files to Create:**

#### 1.1 Create `lib/services/assignment/assignment_business_rules.dart`

```dart
/// Pure business rule functions for assignments
/// No dependencies, no side effects - easy to test

/// Determine if an assignment should be deleted based on count
bool isEmptyAssignment(Assignment assignment) {
  return assignment.count == 0;
}

/// Calculate remaining quantity available for assignment
int calculateRemainingQuantity({
  required int totalAmount,
  required int alreadyAssigned,
}) {
  final remaining = totalAmount - alreadyAssigned;
  return remaining < 0 ? 0 : remaining;
}

/// Calculate assignment delta for work log tracking
/// Returns the change in quantity (positive = added, negative = removed)
int calculateAssignmentDelta({
  required Assignment? currentAssignment,
  required int newAmount,
}) {
  final currentCount = currentAssignment?.count ?? 0;
  return newAmount - currentCount;
}

/// Validate assignment quantity is valid
/// Returns error message if invalid, null if valid
String? validateAssignmentQuantity({
  required int requestedAmount,
  required int availableAmount,
  required int currentlyAssigned,
}) {
  if (requestedAmount < 0) {
    return 'Amount cannot be negative';
  }

  final availableAfterRemovingCurrent = availableAmount + currentlyAssigned;

  if (requestedAmount > availableAfterRemovingCurrent) {
    return 'Insufficient quantity. Available: $availableAfterRemovingCurrent, Requested: $requestedAmount';
  }

  return null; // Valid
}

/// Check if assignment already exists for item-container pair
bool assignmentExists({
  required List<Assignment> allAssignments,
  required String itemId,
  required String containerId,
}) {
  return allAssignments.any(
    (a) => a.itemId == itemId && a.containerId == containerId,
  );
}

/// Get total assigned quantity for an item
int getTotalAssignedForItem({
  required List<Assignment> allAssignments,
  required String itemId,
}) {
  return allAssignments
      .where((a) => a.itemId == itemId)
      .fold(0, (sum, assignment) => sum + assignment.count);
}

/// Get total assigned quantity in a container
int getTotalAssignedInContainer({
  required List<Assignment> allAssignments,
  required String containerId,
}) {
  return allAssignments
      .where((a) => a.containerId == containerId)
      .fold(0, (sum, assignment) => sum + assignment.count);
}
```

**Testing:**
Create `test/services/assignment/assignment_business_rules_test.dart`:
- Test each pure function with various inputs
- No mocking needed - these are pure functions
- Cover edge cases (negative numbers, zero, null assignments)

**Acceptance Criteria:**
- ✅ All pure functions in `assignment_business_rules.dart` created
- ✅ All functions have tests with >90% coverage
- ✅ Tests pass
- ✅ No dependencies on repositories or providers
- ✅ Code generation runs successfully (`dart run build_runner build`)

---

### Phase 2: Service Layer - Assignment Service

**Goal:** Create service to orchestrate assignment operations with work log integration.

**Files to Create:**

#### 2.1 Create `lib/services/assignment/assignment_service.dart`

```dart
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/assignment_repository.dart';
import 'package:rescuenet_warehouse/repositories/work_log_repository.dart';
import 'package:rescuenet_warehouse/services/assignment/assignment_business_rules.dart';
import 'package:rescuenet_warehouse/main.dart';

/// Service for managing assignment operations with side effects
///
/// Orchestrates:
/// - Assignment CRUD operations
/// - Work log creation (audit trail)
/// - Business rule validation
///
/// This service ensures assignments and work logs are created together,
/// maintaining data consistency and centralizing business logic.
class AssignmentService {
  final AssignmentRepository _assignmentRepository;
  final WorkLogRepository _workLogRepository;
  final String _currentUser;

  AssignmentService({
    required AssignmentRepository assignmentRepository,
    required WorkLogRepository workLogRepository,
    required String currentUser,
  })  : _assignmentRepository = assignmentRepository,
        _workLogRepository = workLogRepository,
        _currentUser = currentUser;

  /// Update or create assignment with automatic work log creation
  ///
  /// If newAmount is 0, the assignment will be deleted.
  /// If assignment doesn't exist and newAmount > 0, it will be created.
  ///
  /// Returns the updated/created assignment, or null if deleted.
  /// Throws exception if operation fails.
  Future<Assignment?> updateAssignment({
    required String itemId,
    required String containerId,
    required int newAmount,
  }) async {
    // 1. Get current assignment
    final currentAssignment = await _assignmentRepository.getAssignmentByIds(
      itemId,
      containerId,
    );

    // 2. Calculate delta for work log
    final delta = calculateAssignmentDelta(
      currentAssignment: currentAssignment,
      newAmount: newAmount,
    );

    // 3. If no change, return early
    if (delta == 0) {
      return currentAssignment;
    }

    // 4. Create or update assignment
    Assignment? resultAssignment;

    if (isEmptyAssignment(Assignment(
      id: currentAssignment?.id ?? '',
      itemId: itemId,
      containerId: containerId,
      count: newAmount,
    ))) {
      // Delete if count is 0
      if (currentAssignment != null) {
        await _assignmentRepository.deleteAssignment(currentAssignment.id);
      }
      resultAssignment = null;
    } else {
      // Create or update
      final assignment = currentAssignment?.copyWith(count: newAmount) ??
          Assignment(
            id: uuid.v4(),
            itemId: itemId,
            containerId: containerId,
            count: newAmount,
          );

      await _assignmentRepository.upsertAssignment(assignment);
      resultAssignment = assignment;
    }

    // 5. Create work log entry (only if assignment operation succeeded)
    final workLog = LogEntry(
      id: uuid.v4(),
      itemId: itemId,
      containerId: containerId,
      count: delta,
      date: DateTime.now(),
      user: _currentUser,
    );

    await _workLogRepository.upsertWorkLog(workLog);

    return resultAssignment;
  }

  /// Create a new assignment with initial quantity
  ///
  /// Throws if assignment already exists.
  /// Automatically creates work log entry.
  Future<Assignment> createAssignment({
    required String itemId,
    required String containerId,
    required int initialCount,
  }) async {
    if (initialCount <= 0) {
      throw ArgumentError('Initial count must be greater than 0');
    }

    // Check if assignment already exists
    final existing = await _assignmentRepository.getAssignmentByIds(
      itemId,
      containerId,
    );

    if (existing != null) {
      throw StateError('Assignment already exists for item $itemId in container $containerId');
    }

    // Create new assignment
    final assignment = Assignment(
      id: uuid.v4(),
      itemId: itemId,
      containerId: containerId,
      count: initialCount,
    );

    await _assignmentRepository.upsertAssignment(assignment);

    // Create work log
    final workLog = LogEntry(
      id: uuid.v4(),
      itemId: itemId,
      containerId: containerId,
      count: initialCount,
      date: DateTime.now(),
      user: _currentUser,
    );

    await _workLogRepository.upsertWorkLog(workLog);

    return assignment;
  }

  /// Delete an assignment
  ///
  /// Creates work log entry with negative count to track removal.
  Future<void> deleteAssignment({
    required String assignmentId,
    required String itemId,
    required String containerId,
    required int currentCount,
  }) async {
    await _assignmentRepository.deleteAssignment(assignmentId);

    // Create work log entry for deletion
    final workLog = LogEntry(
      id: uuid.v4(),
      itemId: itemId,
      containerId: containerId,
      count: -currentCount,
      date: DateTime.now(),
      user: _currentUser,
    );

    await _workLogRepository.upsertWorkLog(workLog);
  }

  /// Batch update multiple assignments
  ///
  /// All operations succeed or fail together (via repository batch).
  /// Creates work log entries for all changes.
  Future<void> batchUpdateAssignments({
    required List<Assignment> assignments,
    required List<int> deltas,
  }) async {
    if (assignments.length != deltas.length) {
      throw ArgumentError('Assignments and deltas must have same length');
    }

    // Update assignments in batch
    await _assignmentRepository.batchUpdateAssignments(assignments);

    // Create work log entries for all changes
    final workLogs = List.generate(assignments.length, (index) {
      return LogEntry(
        id: uuid.v4(),
        itemId: assignments[index].itemId,
        containerId: assignments[index].containerId,
        count: deltas[index],
        date: DateTime.now(),
        user: _currentUser,
      );
    }).where((log) => log.count != 0).toList(); // Only log actual changes

    // Note: WorkLogRepository should support batch operations for efficiency
    // For now, insert individually
    for (final log in workLogs) {
      await _workLogRepository.upsertWorkLog(log);
    }
  }
}
```

#### 2.2 Create Riverpod Provider for AssignmentService

Add to `lib/services/assignment/assignment_service.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/repositories/auth_providers.dart';

part 'assignment_service.g.dart';

@riverpod
AssignmentService assignmentService(AssignmentServiceRef ref) {
  return AssignmentService(
    assignmentRepository: ref.watch(assignmentRepositoryProvider),
    workLogRepository: ref.watch(workLogRepositoryProvider),
    currentUser: ref.watch(currentUserNameProvider) ?? 'Unknown',
  );
}
```

**Testing:**
Create `test/services/assignment/assignment_service_test.dart`:
- Mock `AssignmentRepository` and `WorkLogRepository`
- Test `updateAssignment` with various scenarios:
  - Creating new assignment
  - Updating existing assignment
  - Deleting assignment (count = 0)
  - No-op when delta is 0
- Test `createAssignment`:
  - Success case
  - Throws when assignment exists
  - Throws when count <= 0
- Test work log creation happens for all operations
- Verify deltas are calculated correctly

**Acceptance Criteria:**
- ✅ `AssignmentService` class created with all methods
- ✅ Riverpod provider created and generates correctly
- ✅ Tests cover all methods with >85% coverage
- ✅ Tests verify work logs are created for each operation
- ✅ Code generation runs successfully

---

### Phase 3: Remove Business Logic from Repository

**Goal:** Clean up repository to be pure data access layer.

#### 3.1 Update `FirebaseAssignmentRepository`

**File:** `lib/repositories/impl/firebase/firebase_assignment_repository.dart`

**Changes:**
1. **REMOVE** `upsertOrDeleteAssignment` method (lines 125-136)
   - This business logic now lives in `AssignmentService`
   - Service layer decides when to delete vs upsert

2. Update `AssignmentRepository` interface:
   - Remove `upsertOrDeleteAssignment` from interface

**File:** `lib/repositories/assignment_repository.dart`

Remove this method:
```dart
Future<void> upsertOrDeleteAssignment(Assignment assignment);
```

**Migration Notes:**
- Any code calling `repository.upsertOrDeleteAssignment()` will now use `assignmentService.updateAssignment()`
- This is a breaking change but will be fixed in Phase 4

**Acceptance Criteria:**
- ✅ `upsertOrDeleteAssignment` removed from repository interface
- ✅ `upsertOrDeleteAssignment` removed from Firebase implementation
- ✅ `upsertOrDeleteAssignment` removed from Mock implementation
- ✅ Repository only has CRUD operations (get, upsert, delete, batch)
- ✅ Code compiles (may have errors in state/UI - will fix in Phase 4)

---

### Phase 4: Refactor State Notifiers to Use Service

**Goal:** Simplify state notifiers to delegate to `AssignmentService`.

#### 4.1 Update `CurrentItemAssignmentsNotifier`

**File:** `lib/state/current_item_assignments_notifier.dart`

**Changes:**

1. **Update `addContainerAssignment` method** (lines 57-81):

BEFORE:
```dart
addContainerAssignment(String containerIdToAdd, int amount) {
  var currentItem = ref.read(currentItemNotifierProvider);

  var existingAssignment = ref
      .read(allAssignmentsAsyncProvider.notifier)
      .byIds(currentItem!.id, containerIdToAdd);

  if (existingAssignment != null) {
    setAmount(containerIdToAdd, amount);
    return;
  }

  var assignment = Assignment(
    id: uuid.v4(),
    itemId: currentItem.id,
    containerId: containerIdToAdd,
    count: amount,
  );

  ref.read(assignmentRepositoryProvider).upsertAssignment(assignment);
  var log = _buildEntry(currentItem, containerIdToAdd, amount);
  ref.read(workLogRepositoryProvider).upsertWorkLog(log);
}
```

AFTER:
```dart
Future<void> addContainerAssignment(String containerIdToAdd, int amount) async {
  final currentItem = ref.read(currentItemNotifierProvider);
  if (currentItem == null) return;

  final service = ref.read(assignmentServiceProvider);

  // Service handles checking for existing assignment
  await service.updateAssignment(
    itemId: currentItem.id,
    containerId: containerIdToAdd,
    newAmount: amount,
  );
}
```

2. **Update `setAmount` method** (lines 83-105):

BEFORE:
```dart
setAmount(String containerId, int amount) {
  var item = ref.read(currentItemNotifierProvider)!;
  var current = ref
      .read(allAssignmentsAsyncProvider.notifier)
      .byIds(item.id, containerId);

  if (current != null) {
    ref.read(assignmentRepositoryProvider).upsertOrDeleteAssignment(current.copyWith(count: amount));
    var log = _buildEntry(item, containerId, amount - current.count);
    ref.read(workLogRepositoryProvider).upsertWorkLog(log);
  } else if (amount > 0) {
    var assignment = Assignment(
      id: uuid.v4(),
      itemId: item.id,
      containerId: containerId,
      count: amount,
    );
    ref.read(assignmentRepositoryProvider).upsertAssignment(assignment);
    var log = _buildEntry(item, containerId, amount);
    ref.read(workLogRepositoryProvider).upsertWorkLog(log);
  }
}
```

AFTER:
```dart
Future<void> setAmount(String containerId, int amount) async {
  final item = ref.read(currentItemNotifierProvider);
  if (item == null) return;

  final service = ref.read(assignmentServiceProvider);

  await service.updateAssignment(
    itemId: item.id,
    containerId: containerId,
    newAmount: amount,
  );
}
```

3. **REMOVE `_buildEntry` method** (lines 107-114):
   - No longer needed - service creates work logs

4. **Remove unused imports:**
   - Remove `workLogRepositoryProvider` import
   - Remove `assignmentRepositoryProvider` import
   - Remove `LogEntry` import
   - Add `assignmentServiceProvider` import

**Acceptance Criteria:**
- ✅ `addContainerAssignment` delegates to service
- ✅ `setAmount` delegates to service
- ✅ `_buildEntry` method removed
- ✅ No direct calls to repositories
- ✅ No work log creation logic
- ✅ Code compiles and runs
- ✅ Manual test: Can still add/update assignments from item edit page

#### 4.2 Update `AssignmentByContainerState`

**File:** `lib/features/assignment_by_container/assign_by_container/assignment_by_container_state.dart`

**Changes:**

1. **Update `addItem` method** (lines 37-52):

BEFORE:
```dart
Future<void> addItem(String containerId, Item item) async {
  if (state.keys.map((i) => i.id).contains(item.id)) {
    print("Assignment for item already exists. Doing nothing");
    return;
  }

  var assignment = Assignment(
    id: uuid.v4(),
    itemId: item.id,
    containerId: containerId,
    count: 1,
  );

  await ref.read(dataOperationsNotifierProvider.notifier).createAssignment(assignment);
}
```

AFTER:
```dart
Future<void> addItem(String containerId, Item item) async {
  if (state.keys.map((i) => i.id).contains(item.id)) {
    // Assignment for item already exists. Doing nothing.
    return;
  }

  final service = ref.read(assignmentServiceProvider);

  try {
    await service.createAssignment(
      itemId: item.id,
      containerId: containerId,
      initialCount: 1,
    );
  } catch (e) {
    // Service will throw if assignment exists, which shouldn't happen
    // due to check above, but handle gracefully
    rethrow;
  }
}
```

2. **Update `upsert` method** (lines 54-57):

BEFORE:
```dart
Future<void> upsert(Assignment assignment) async {
  await ref.read(dataOperationsNotifierProvider.notifier).upsertOrDeleteAssignment(assignment);
}
```

AFTER:
```dart
Future<void> upsert(Assignment assignment) async {
  final service = ref.read(assignmentServiceProvider);

  await service.updateAssignment(
    itemId: assignment.itemId,
    containerId: assignment.containerId,
    newAmount: assignment.count,
  );
}
```

3. **Update `AssignmentByContainerAsync` class** similarly (lines 108-132):

Update `addItem` and `upsert` methods to use service instead of `DataOperationsNotifier`.

**Acceptance Criteria:**
- ✅ Both `addItem` methods delegate to service
- ✅ Both `upsert` methods delegate to service
- ✅ Code compiles and runs
- ✅ Manual test: Can add items to container from container assignment page
- ✅ Manual test: Can update quantities in container view

---

### Phase 5: Update DataOperationsNotifier

**Goal:** Remove or deprecate `upsertOrDeleteAssignment` method from `DataOperationsNotifier`.

**File:** `lib/state/data_operations_notifier.dart`

**Changes:**

**Option A: Remove the method entirely** (breaking change):
- Delete `upsertOrDeleteAssignment` method (lines 333-349)
- Update any remaining callers to use `AssignmentService`

**Option B: Deprecate and delegate to service** (non-breaking):
```dart
/// @deprecated Use AssignmentService.updateAssignment instead
/// This method will be removed in a future version.
Future<void> upsertOrDeleteAssignment(Assignment assignment) async {
  _setOperationState(DataOperation.assignmentUpdate, const AsyncValue.loading());

  try {
    final service = ref.read(assignmentServiceProvider);
    await service.updateAssignment(
      itemId: assignment.itemId,
      containerId: assignment.containerId,
      newAmount: assignment.count,
    );
    _setOperationState(DataOperation.assignmentUpdate, const AsyncValue.data(null));
  } catch (error, stackTrace) {
    _setOperationState(
      DataOperation.assignmentUpdate,
      AsyncValue.error(error, stackTrace),
    );
    rethrow;
  }
}
```

**Recommendation:** Use Option B for now, remove in future version after confirming no other callers.

**Acceptance Criteria:**
- ✅ Method either removed or marked deprecated
- ✅ All callers updated to use `AssignmentService` directly
- ✅ Tests still pass
- ✅ Code compiles

---

### Phase 6: Update UI Components

**Goal:** Simplify UI components to use service, remove business logic from widgets.

#### 6.1 Update `AssignmentByContainerSingleItem`

**File:** `lib/features/assignment_by_container/assign_by_container/assignment_by_container_single_item.dart`

**Changes:**

1. **Simplify `_updateAssignmentCount` method** (lines 69-112):

BEFORE:
```dart
Future<void> _updateAssignmentCount(...) async {
  await ref.executeWithDebouncedLoading(
    operationKey: operationKey,
    config: DebouncedLoadingConfig.quick,
    operation: () async {
      ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.assignmentUpdate);

      final updatedAssignment = _assignment.copyWith(count: newCount);

      await ref.read(dataOperationsNotifierProvider.notifier)
          .upsertOrDeleteAssignment(updatedAssignment);

      if (context.mounted && (newCount == 0 || (_assignment.count == 0 && newCount > 0))) {
        final message = newCount == 0
            ? 'Removed ${_item.name} from container'
            : 'Added ${_item.name} to container';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    },
  ).catchError((error) {
    // ... error handling
  });
}
```

AFTER:
```dart
Future<void> _updateAssignmentCount(
  BuildContext context,
  WidgetRef ref,
  String operationKey,
  int newCount,
) async {
  await ref.executeWithDebouncedLoading(
    operationKey: operationKey,
    config: DebouncedLoadingConfig.quick,
    operation: () async {
      final service = ref.read(assignmentServiceProvider);

      await service.updateAssignment(
        itemId: _assignment.itemId,
        containerId: _assignment.containerId,
        newAmount: newCount,
      );

      // Show success message for significant changes
      if (context.mounted) {
        _showSuccessMessage(context, newCount);
      }
    },
  ).catchError((error) {
    if (context.mounted) {
      _showErrorMessage(context, error, operationKey, newCount);
    }
  });
}

void _showSuccessMessage(BuildContext context, int newCount) {
  // Only show message for significant changes (adding first item or removing last)
  if (newCount == 0 || (_assignment.count == 0 && newCount > 0)) {
    final message = newCount == 0
        ? 'Removed ${_item.name} from container'
        : 'Added ${_item.name} to container';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

void _showErrorMessage(
  BuildContext context,
  Object error,
  String operationKey,
  int newCount,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to update assignment: ${error.toString()}'),
      backgroundColor: Theme.of(context).colorScheme.error,
      action: SnackBarAction(
        label: 'Try Again',
        onPressed: () => _updateAssignmentCount(context, ref, operationKey, newCount),
        textColor: Theme.of(context).colorScheme.onError,
      ),
    ),
  );
}
```

**Benefits:**
- ✅ Cleaner separation of concerns (operation vs presentation)
- ✅ Service handles all business logic
- ✅ Widget only handles UI feedback
- ✅ Easier to test presentation logic separately

**Acceptance Criteria:**
- ✅ Widget uses `AssignmentService` instead of `DataOperationsNotifier`
- ✅ Success/error message logic extracted to separate methods
- ✅ Code compiles and runs
- ✅ Manual test: Can increment/decrement quantities in container view
- ✅ Manual test: Setting count to 0 removes assignment
- ✅ Manual test: Success/error messages appear correctly

---

### Phase 7: Validation Integration (Optional Enhancement)

**Goal:** Add validation to prevent invalid assignments (over-assignment).

#### 7.1 Add Validation to AssignmentService

**File:** `lib/services/assignment/assignment_service.dart`

Add optional validation to `updateAssignment`:

```dart
/// Update or create assignment with automatic work log creation
///
/// If [validateQuantity] is true and [item] is provided, validates that
/// the assignment doesn't exceed available quantity.
Future<Assignment?> updateAssignment({
  required String itemId,
  required String containerId,
  required int newAmount,
  bool validateQuantity = false,
  Item? item,
  List<Assignment>? allAssignments,
}) async {
  // Validation (if requested)
  if (validateQuantity && item != null && allAssignments != null) {
    final currentAssignment = allAssignments.firstWhereOrNull(
      (a) => a.itemId == itemId && a.containerId == containerId,
    );

    final totalAssigned = getTotalAssignedForItem(
      allAssignments: allAssignments,
      itemId: itemId,
    );

    final currentlyAssignedHere = currentAssignment?.count ?? 0;
    final availableAmount = item.totalAmount - totalAssigned + currentlyAssignedHere;

    final validationError = validateAssignmentQuantity(
      requestedAmount: newAmount,
      availableAmount: availableAmount,
      currentlyAssigned: currentlyAssignedHere,
    );

    if (validationError != null) {
      throw ArgumentError(validationError);
    }
  }

  // ... rest of method stays the same
}
```

#### 7.2 Use Validation in UI (where needed)

Update components that should validate:

```dart
// In assignment_by_container_single_item.dart or item_edit_page_amounts.dart
final allAssignments = await ref.read(allAssignmentsAsyncProvider.future);
final item = _item; // or get from provider

await service.updateAssignment(
  itemId: item.id,
  containerId: containerId,
  newAmount: newCount,
  validateQuantity: true,  // Enable validation
  item: item,
  allAssignments: allAssignments,
);
```

**Note:** This is optional - only add if you want to enforce quantity validation in the UI.

**Acceptance Criteria:**
- ✅ Validation parameter added to service (default false for backward compatibility)
- ✅ Validation uses pure business rule functions
- ✅ Tests verify validation works correctly
- ✅ UI components can opt-in to validation
- ✅ Error messages are user-friendly

---

### Phase 8: Testing & Cleanup

**Goal:** Ensure everything works together, remove deprecated code.

#### 8.1 Integration Testing

**Manual Test Scenarios:**

1. **Item Edit Page - Assignment Tab:**
   - ✅ Add container assignment with initial quantity
   - ✅ Increase quantity
   - ✅ Decrease quantity
   - ✅ Set quantity to 0 (should remove assignment)
   - ✅ Verify work log entries created for each change

2. **Container Assignment Page:**
   - ✅ Add new item to container
   - ✅ Increase item quantity with +1 button
   - ✅ Decrease item quantity with -1 button
   - ✅ Reduce to 0 (should remove from list)
   - ✅ Verify debounced loading works smoothly

3. **Search & Assign:**
   - ✅ Search for items
   - ✅ Add item to container
   - ✅ Verify can't add same item twice
   - ✅ Verify only assignable items shown

4. **Work Logs:**
   - ✅ Check Firestore work_logs collection
   - ✅ Verify entries created for all assignment changes
   - ✅ Verify deltas are correct (positive for add, negative for remove)
   - ✅ Verify user attribution is correct

#### 8.2 Cleanup Tasks

1. **Remove deprecated code:**
   - Remove `upsertOrDeleteAssignment` from `DataOperationsNotifier` (if marked deprecated in Phase 5)
   - Search codebase for any remaining direct calls to repositories for assignments
   - Remove unused imports

2. **Code formatting:**
   - Run `dart format lib/`
   - Run `dart fix --apply`

3. **Final code generation:**
   - Run `dart run build_runner build --delete-conflicting-outputs`

4. **Final test run:**
   - Run all tests: `flutter test`
   - Verify all pass

**Acceptance Criteria:**
- ✅ All manual test scenarios pass
- ✅ All automated tests pass
- ✅ No compilation warnings
- ✅ No TODO/FIXME comments left in code
- ✅ Code formatted consistently
- ✅ Work logs correctly created in Firestore

---

## Migration Checklist

Before deploying to production:

- [ ] All phases completed
- [ ] All tests passing (unit + integration)
- [ ] Manual testing completed for all scenarios
- [ ] Code review completed
- [ ] No breaking changes to existing functionality
- [ ] Work logs verified in staging environment
- [ ] Performance testing (no significant regressions)
- [ ] Documentation updated (if applicable)
- [ ] Deployment plan reviewed

---

## Rollback Plan

If issues arise in production:

1. **Immediate rollback:**
   - Revert to previous git commit
   - Deploy previous version
   - Monitor for stability

2. **Debug in staging:**
   - Reproduce issue in staging environment
   - Fix and test thoroughly
   - Re-deploy when stable

3. **Data integrity:**
   - Work logs should not be affected (append-only)
   - Assignments remain compatible (same data model)
   - No migration scripts needed

---

## Success Metrics

After completion, verify:

1. **Code Quality:**
   - ✅ Business logic centralized in service layer
   - ✅ Pure functions have high test coverage (>90%)
   - ✅ State notifiers simplified (50% fewer lines in assignment notifiers)
   - ✅ No business logic in repositories
   - ✅ No business logic in UI components

2. **Functionality:**
   - ✅ All existing features work as before
   - ✅ Work logs correctly track all changes
   - ✅ UI remains responsive and smooth

3. **Maintainability:**
   - ✅ Easier to add new assignment-related features
   - ✅ Easier to test business rules
   - ✅ Clear separation of concerns throughout codebase

---

## Future Improvements (Out of Scope)

After this refactor, consider:

1. **Result Type:** Replace exception throwing with Result<T, E> type for better error handling
2. **Transaction Support:** Explore Firestore transactions for assignments + work logs
3. **Optimistic Updates:** Add optimistic UI updates for better perceived performance
4. **Batch Operations:** Expand batch support for bulk assignment operations
5. **Undo/Redo:** Use work logs to implement undo functionality
6. **Analytics:** Track assignment patterns for inventory insights

---

## Notes for Claude Code Execution

When executing this plan:

1. **Phase-by-Phase:** Complete each phase fully before moving to next
2. **Run Code Generation:** After each phase that adds/modifies providers
3. **Test Frequently:** Run tests after each file modification
4. **Commit Often:** Commit after each phase for easy rollback
5. **Ask for Clarification:** If business logic is ambiguous, ask user before implementing
6. **Preserve Behavior:** Existing functionality should work exactly the same after refactor

**Estimated Time:**
- Phase 1-2: 30-45 minutes (foundation + service)
- Phase 3-4: 20-30 minutes (repository cleanup + state refactor)
- Phase 5-6: 20-30 minutes (operations notifier + UI)
- Phase 7: 15-20 minutes (optional validation)
- Phase 8: 30-45 minutes (testing + cleanup)

**Total:** 2-3 hours for complete refactoring with testing
