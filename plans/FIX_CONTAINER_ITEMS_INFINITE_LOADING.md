# Fix Container Items Infinite Loading Issue

## Problem Summary

**Root Cause**: List reference equality in Riverpod family providers causes infinite provider recreation loop.

**Location**: `lib/ui/container_with_content/container_with_content_column.dart:34-40`

**Current (Broken) Flow**:
1. Widget builds → creates new `List<String>` with `.toList()`
2. Passes list to `itemsByIdsProvider(itemIds)`
3. Dart uses reference equality for Lists (`[1,2] == [1,2]` → false)
4. Riverpod sees different reference → creates new provider instance
5. AutoDispose kills old provider → new provider starts loading
6. Loading triggers rebuild → goto step 1 → **INFINITE LOOP**

**Why Unassigned Works**: Uses `assignableItemsAsyncProvider` (no parameters = no equality checks)

## Solution Approach

**Strategy**: Pass `containerId` (String - has value equality) instead of `List<String>` as family parameter.

Create a new provider that:
- Takes `containerId` as parameter (String with proper value equality)
- Internally watches assignments for that container
- Derives itemIds from assignments inside the provider
- Watches items using those IDs
- Returns Stream of items

Uses stream composition (switchMap) to handle assignment changes → switch to new items stream.

## Implementation Steps

### Step 1: Add rxdart Dependency

**File**: `pubspec.yaml`

**Action**: Add rxdart for stream composition (switchMap)

**Command**:
```bash
flutter pub add rxdart
```

**Rationale**:
- Industry standard for reactive stream operations
- Tiny dependency (~300KB)
- Provides battle-tested `switchMap` for our exact use case
- Common in Flutter/Firebase projects

**Verification**: Check that `rxdart` appears in `pubspec.yaml` dependencies

---

### Step 2: Create New Provider for Items by Container

**File**: `lib/state/items_for_container_notifier.dart` (NEW)

**Action**: Create a provider that takes containerId and returns items for that container

**Implementation**:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/assignments_by_container_notifier.dart';

part 'items_for_container_notifier.g.dart';

/// Watches items assigned to a specific container.
///
/// Automatically updates when:
/// - Assignments for this container change
/// - Items in this container change
///
/// This provider solves the infinite loading issue by using containerId
/// (String with value equality) instead of List<String> as the family parameter.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsForContainerProvider(containerId));
/// ```
@riverpod
class ItemsForContainer extends _$ItemsForContainer {
  @override
  Stream<List<Item>> build(String containerId) {
    // Watch assignments stream for this container
    final assignmentsStream = ref.watch(
      assignmentsByContainerProvider(containerId),
    );
    final repository = ref.watch(itemRepositoryProvider);

    // When assignments change, switch to watching the new set of items
    return assignmentsStream.switchMap((assignments) {
      // Extract item IDs from assignments (pure function - no side effects)
      final itemIds = assignments
          .where((a) => a.count > 0)
          .map((a) => a.itemId)
          .toList();

      // Handle empty case early
      if (itemIds.isEmpty) {
        return Stream.value([]);
      }

      // Watch items for these IDs
      // When assignments change, switchMap cancels the old stream
      // and switches to the new items stream
      return repository.watchItemsByIds(itemIds);
    });
  }
}
```

**Key Design Decisions**:
- **SRP**: Provider does one thing - provide items for a container
- **Pure derivation**: itemIds extraction is pure function logic
- **Modularity**: Reuses existing `assignmentsByContainerProvider` and repository
- **KISS**: Simple stream composition, no manual stream management
- **Value equality**: String parameter avoids reference equality issue

**Verification**: File created with correct imports and annotations

---

### Step 3: Run Code Generation

**Action**: Generate Riverpod provider code

**Command**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Expected Output**:
- Creates `lib/state/items_for_container_notifier.g.dart`
- No build errors

**Verification**: Generated file exists and contains `ItemsForContainerProvider` class

---

### Step 4: Update UI to Use New Provider

**File**: `lib/ui/container_with_content/container_with_content_column.dart`

**Action**: Replace broken itemsByIds usage with new itemsForContainer provider

**Changes**:

1. Update imports (add new provider):
```dart
import 'package:rescuenet_warehouse/state/items_for_container_notifier.dart';
```

2. Simplify the build method by removing nested AsyncValueBuilder:

**OLD (lines 20-51)**:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return AsyncValueBuilder<List<Assignment>>(
    value: ref.watch(assignmentsByContainerProvider(_container.id)),
    loading: () => const DataLoadingIndicator(
      message: 'Loading container assignments...',
    ),
    error: (error, stackTrace) => ErrorRetryWidget(
      error: error,
      message: 'Failed to load container assignments',
      onRetry: () => ref.refresh(assignmentsByContainerProvider(_container.id)),
    ),
    data: (containerAssignments) {
      // Extract item IDs from assignments for fine-grained watching
      final itemIds = containerAssignments
          .where((a) => a.count > 0)
          .map((a) => a.itemId)
          .toList();

      return AsyncValueBuilder<List<Item>>(
        value: ref.watch(itemsByIdsProvider(itemIds)),
        loading: () => const DataLoadingIndicator(message: 'Loading items...'),
        error: (error, stackTrace) => ErrorRetryWidget(
          error: error,
          message: 'Failed to load items',
          onRetry: () => ref.refresh(itemsByIdsProvider(itemIds)),
        ),
        data: (items) => _buildContainerContent(containerAssignments, items),
      );
    },
  );
}
```

**NEW**:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Watch both assignments and items for this container
  // Both providers take containerId (String) - no list equality issues
  final assignmentsAsync = ref.watch(
    assignmentsByContainerProvider(_container.id),
  );
  final itemsAsync = ref.watch(
    itemsForContainerProvider(_container.id),
  );

  // Show loading if either is loading
  if (assignmentsAsync.isLoading || itemsAsync.isLoading) {
    return const DataLoadingIndicator(message: 'Loading container items...');
  }

  // Show error if either has error (prioritize assignments error)
  final error = assignmentsAsync.error ?? itemsAsync.error;
  if (error != null) {
    return ErrorRetryWidget(
      error: error,
      message: 'Failed to load container data',
      onRetry: () {
        ref.refresh(assignmentsByContainerProvider(_container.id));
        ref.refresh(itemsForContainerProvider(_container.id));
      },
    );
  }

  // Both have data - build content
  final assignments = assignmentsAsync.valueOrNull ?? [];
  final items = itemsAsync.valueOrNull ?? [];

  return _buildContainerContent(assignments, items);
}
```

3. Remove import for old provider (if not used elsewhere):
```dart
// REMOVE: import 'package:rescuenet_warehouse/state/items_by_ids_notifier.dart';
```

**Rationale**:
- **Simpler**: Single level async handling instead of nested
- **Clearer**: Explicit loading/error states
- **Faster**: Both streams load in parallel
- **KISS**: Straightforward conditional logic

**Verification**:
- Code compiles without errors
- No more nested AsyncValueBuilders
- Loading states are handled properly

---

### Step 5: Test the Fix

**Action**: Manual testing in development environment

**Test Cases**:

1. **Container with items loads successfully**:
   - Navigate to ContainerWithContent page
   - Select a container with assigned items
   - ✅ Items should appear (no infinite "Loading items...")
   - ✅ Items should match assignments

2. **Empty container shows empty state**:
   - Select a container with no assignments
   - ✅ Should show "No items assigned" message
   - ✅ No infinite loading

3. **Unassigned items still work**:
   - Check unassigned items section
   - ✅ Should display correctly (already working)
   - ✅ Verify no regression

4. **Reactivity works correctly**:
   - Assign an item to a container (from another screen/session)
   - ✅ Container view should update automatically
   - ✅ Item should appear in container

5. **Error handling**:
   - Disconnect network or cause Firestore error
   - ✅ Error message should display
   - ✅ Retry button should work

**Manual Test Commands**:
```bash
# Run in Chrome for easy debugging
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging
```

**Verification**: All test cases pass

---

### Step 6: Clean Up Old Provider (Optional)

**File**: `lib/state/items_by_ids_notifier.dart`

**Action**: Check if provider is used elsewhere, remove if not

**Commands**:
```bash
# Search for usage
grep -r "itemsByIdsProvider" lib/ --exclude-dir=*.g.dart

# If only used in container_with_content_column.dart (already removed),
# delete the provider files:
rm lib/state/items_by_ids_notifier.dart
rm lib/state/items_by_ids_notifier.g.dart
```

**Rationale**:
- Dead code elimination
- Prevents future confusion
- Keeps codebase lean

**Decision Point**:
- If used elsewhere: Keep it and document the list equality issue
- If not used: Delete it

**Verification**: No compilation errors after deletion (if deleted)

---

### Step 7: Update Documentation (Optional)

**File**: `plans/FINE_GRAINED_REACTIVITY_ITEMS.md`

**Action**: Add a note about the fix and the list equality lesson

**Addition**:
```markdown
## Lessons Learned

### List Equality in Riverpod Family Providers

**Issue Discovered**: Using `List<String>` as a family provider parameter causes infinite recreation loops because Dart Lists use reference equality, not value equality.

**Symptom**: Infinite "Loading..." state, provider constantly recreating

**Root Cause**:
- Widget builds create new list with `.toList()`
- Riverpod sees different reference → new provider
- AutoDispose kills old → new starts loading → rebuild → loop

**Solution**: Use parameters with value equality (String, int) instead of Lists
- Pass `containerId` instead of `List<String> itemIds`
- Derive lists inside the provider where they won't trigger recreation

**Example**: `itemsForContainerProvider(containerId)` replaces `itemsByIdsProvider(itemIds)`

**Fixed**: 2025-12-16 (this plan)
```

**Verification**: Documentation updated with lessons learned

---

## Success Criteria

- ✅ Containers show items without infinite loading
- ✅ Loading states display correctly
- ✅ Empty containers show empty state
- ✅ Reactivity works (items update when assignments change)
- ✅ No regressions in unassigned items view
- ✅ Error handling works properly
- ✅ Code follows SRP, KISS, modularity principles
- ✅ No new dependencies except rxdart (standard library)

## Rollback Plan

If issues arise:

1. **Quick rollback** (revert to all items):
   ```dart
   // In container_with_content_column.dart
   final itemsAsync = ref.watch(allItemsAsyncProvider);
   ```
   - Loses fine-grained reactivity but works immediately

2. **Full rollback**:
   ```bash
   git checkout HEAD^ lib/ui/container_with_content/container_with_content_column.dart
   git checkout HEAD^ lib/state/items_for_container_notifier.dart
   dart run build_runner build --delete-conflicting-outputs
   ```

## Technical Debt / Future Considerations

- **None**: This is the correct Riverpod pattern for this use case
- If rxdart becomes a concern, could implement custom switchMap, but unnecessary optimization
- Consider similar pattern for other views with list-based family providers

## Estimated Time

- Senior developer: 15-20 minutes
- Including testing: 30 minutes
- Total: **< 1 hour**

## Dependencies

- rxdart (new, standard Flutter library)
- Existing: riverpod, riverpod_annotation, build_runner

## Files Modified

- ✏️ `pubspec.yaml` (add rxdart)
- ➕ `lib/state/items_for_container_notifier.dart` (new)
- ✏️ `lib/ui/container_with_content/container_with_content_column.dart` (simplified)
- ❌ `lib/state/items_by_ids_notifier.dart` (optional deletion)

## Files Generated

- `lib/state/items_for_container_notifier.g.dart` (build_runner)
