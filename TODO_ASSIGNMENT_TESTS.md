# Assignment Integration Tests - COMPLETED

**Status:** ✅ Complete
**File:** `test/integration/assignment_integration_test.dart`
**Test Count:** 13 tests, all passing

This document outlined the plan for implementing integration tests for Assignment operations. The tests have been successfully implemented.

## Overview

Assignment tests should validate the many-to-many relationship between Items and Containers.

**Target file:** `test/integration/assignment_integration_test.dart`

## Assignment Model

**Location:** `lib/models/assignment.dart`

**Fields:**
- `id` (String) - Unique assignment identifier
- `itemId` (String) - Reference to Item
- `containerId` (String) - Reference to Container
- `count` (int) - Quantity of items in this container

**Business Logic:**
- An assignment links an Item to a Container with a quantity
- `count = 0` typically means the assignment should be deleted
- Multiple assignments can exist for same item (different containers)
- Stream updates notify UI of assignment changes

## Repository Interface

**Location:** `lib/repositories/assignment_repository.dart`

**Operations:**
- `upsertAssignment(Assignment)` - Create or update assignment
- `deleteAssignment(String id)` - Delete assignment
- `getAssignment(String id)` - Get by ID
- `getAssignmentsForContainer(String containerId)` - All assignments for a container
- `getAssignmentsForItem(String itemId)` - All assignments for an item
- `getAssignmentByIds(String itemId, String containerId)` - Specific item-container assignment
- `watchAssignments()` - Stream all assignments
- `batchUpdateAssignments(List<Assignment>)` - Batch update
- `batchDeleteAssignments(List<String> ids)` - Batch delete
- `upsertOrDeleteAssignment(Assignment)` - Business logic: count=0 → delete, count>0 → upsert

## Mock Repository

**Location:** `lib/repositories/impl/mock/mock_assignment_repository.dart`

Already exists - review for completeness.

## Test Structure

```dart
void main() {
  group('Assignment Integration Tests', () {
    late MockAssignmentRepository mockRepo;
    late MockItemRepository mockItemRepo;
    late MockContainerRepository mockContainerRepo;

    setUp(() {
      mockRepo = MockAssignmentRepository();
      mockItemRepo = MockItemRepository();
      mockContainerRepo = MockContainerRepository();
      // Setup test items and containers
    });

    tearDown(() {
      mockRepo.dispose();
      mockItemRepo.dispose();
      mockContainerRepo.dispose();
    });

    group('Assign Item to Container', () {
      // Test 1: Create new assignment
      // Test 2: Update existing assignment quantity
    });

    group('Remove Item from Container', () {
      // Test 1: Delete assignment
      // Test 2: Set count to 0 (business logic)
    });

    group('Query Assignments', () {
      // Test 1: Get all assignments for a container
      // Test 2: Get all assignments for an item
      // Test 3: Get specific item-container assignment
    });

    group('Batch Operations', () {
      // Test 1: Batch update multiple assignments
      // Test 2: Batch delete multiple assignments
      // Test 3: Mixed batch operations (create + update)
    });

    group('Business Logic', () {
      // Test 1: upsertOrDeleteAssignment with count > 0 (upserts)
      // Test 2: upsertOrDeleteAssignment with count = 0 (deletes)
      // Test 3: Handle assignment to non-existent item/container
    });

    group('Stream Operations', () {
      // Test 1: Emit on create
      // Test 2: Emit on update
      // Test 3: Emit on delete
      // Test 4: Batch operations emit once
    });

    group('Capacity Validation', () {
      // Test 1: Verify total assigned <= item.totalAmount
      // Test 2: Multiple assignments across containers
      // Test 3: Over-assignment scenario (if validation exists)
    });
  });
}
```

## Test Scenarios

### 1. Basic Assignment Operations

**Create new assignment:**
```dart
final item = createTestItem(id: 'item-1', totalAmount: 100);
final container = createTestContainer(id: 'container-1');

final assignment = Assignment(
  id: 'assignment-1',
  itemId: 'item-1',
  containerId: 'container-1',
  count: 25,
);

await mockRepo.upsertAssignment(assignment);
// Verify assignment exists
// Verify stream emission
```

**Update assignment quantity:**
```dart
// Change count from 25 to 50
final updated = assignment.copyWith(count: 50);
await mockRepo.upsertAssignment(updated);
// Verify new count
```

**Delete assignment:**
```dart
await mockRepo.deleteAssignment('assignment-1');
// Verify assignment removed
// Verify stream emission
```

### 2. Query Operations

**Get assignments for container:**
```dart
// Setup: 3 different items assigned to container-1
final assignments = await mockRepo.getAssignmentsForContainer('container-1');
expect(assignments.length, 3);
```

**Get assignments for item:**
```dart
// Setup: item-1 assigned to 2 different containers
final assignments = await mockRepo.getAssignmentsForItem('item-1');
expect(assignments.length, 2);
```

**Get specific assignment by IDs:**
```dart
final assignment = await mockRepo.getAssignmentByIds('item-1', 'container-1');
expect(assignment, isNotNull);
expect(assignment?.count, 25);
```

### 3. Batch Operations

**Batch update:**
```dart
final assignments = [
  Assignment(id: 'a1', itemId: 'item-1', containerId: 'c1', count: 10),
  Assignment(id: 'a2', itemId: 'item-2', containerId: 'c1', count: 20),
  Assignment(id: 'a3', itemId: 'item-3', containerId: 'c2', count: 15),
];

await mockRepo.batchUpdateAssignments(assignments);
// Verify all 3 assignments created
// Verify single stream emission (not 3)
```

**Batch delete:**
```dart
await mockRepo.batchDeleteAssignments(['a1', 'a2', 'a3']);
// Verify all deleted
// Verify single stream emission
```

### 4. Business Logic: upsertOrDeleteAssignment

**Count > 0 → Upsert:**
```dart
final assignment = Assignment(
  id: 'a1',
  itemId: 'item-1',
  containerId: 'c1',
  count: 15,
);

await mockRepo.upsertOrDeleteAssignment(assignment);
// Verify assignment exists
```

**Count = 0 → Delete:**
```dart
final zeroCount = assignment.copyWith(count: 0);
await mockRepo.upsertOrDeleteAssignment(zeroCount);
// Verify assignment deleted
```

### 5. Capacity Validation

**Verify total assigned ≤ item.totalAmount:**
```dart
final item = createTestItem(id: 'item-1', totalAmount: 100);

// Assign to 3 containers: 40 + 30 + 20 = 90 (valid)
await mockRepo.upsertAssignment(Assignment(id: 'a1', itemId: 'item-1', containerId: 'c1', count: 40));
await mockRepo.upsertAssignment(Assignment(id: 'a2', itemId: 'item-1', containerId: 'c2', count: 30));
await mockRepo.upsertAssignment(Assignment(id: 'a3', itemId: 'item-1', containerId: 'c3', count: 20));

// Get all assignments for item-1
final assignments = await mockRepo.getAssignmentsForItem('item-1');
final totalAssigned = assignments.fold(0, (sum, a) => sum + a.count);

expect(totalAssigned, 90);
expect(totalAssigned, lessThanOrEqualTo(item.totalAmount));
```

**Over-assignment scenario:**
```dart
// Try to assign 110 (more than totalAmount=100)
// Depends on business logic - may allow or throw error
// Document expected behavior
```

### 6. Stream Tests

**Single assignment emits update:**
```dart
final streamFuture = mockRepo.watchAssignments().skip(1).first;
await mockRepo.upsertAssignment(assignment);
final assignments = await streamFuture;
expect(assignments.any((a) => a.id == 'assignment-1'), true);
```

**Batch operations emit once:**
```dart
final streamFuture = mockRepo.watchAssignments().skip(1).first;
await mockRepo.batchUpdateAssignments([a1, a2, a3]);
// Should emit once, not 3 times
```

## Helper Functions Needed

Add to `test/helpers/test_helpers.dart`:

```dart
/// Creates a test Assignment instance
Assignment createTestAssignment({
  String id = 'test-assignment',
  String itemId = 'test-item',
  String containerId = 'test-container',
  int count = 5,
});
```

**Note:** This function already exists - verify it's sufficient.

## Complex Scenarios to Test

### Scenario 1: Move Items Between Containers
```dart
// Initial: item-1 has 50 units in container-1
// Action: Move 20 units to container-2
// Result: container-1 has 30, container-2 has 20
```

### Scenario 2: Empty Container
```dart
// Remove all assignments from a container
final assignments = await mockRepo.getAssignmentsForContainer('c1');
await mockRepo.batchDeleteAssignments(assignments.map((a) => a.id).toList());
// Verify container has 0 assignments
```

### Scenario 3: Redistribute Item Across Multiple Containers
```dart
// Item with totalAmount=100
// Distribute: c1=40, c2=30, c3=30
// Batch update all assignments
// Verify total = 100
```

## Edge Cases

1. **Assignment to non-existent item** - Should fail or create placeholder?
2. **Assignment to non-existent container** - Should fail or create placeholder?
3. **Duplicate assignments** - Same item+container, different IDs?
4. **Negative count** - Should be rejected
5. **Count exceeds totalAmount** - Validation or allowed?
6. **Concurrent updates** - Last write wins or merge?

## Implementation Steps

1. Review `test/integration/item_crud_integration_test.dart` as template
2. Review `MockAssignmentRepository` implementation
3. Create test data setup (items + containers)
4. Create `test/integration/assignment_integration_test.dart`
5. Implement basic CRUD tests
6. Add query operation tests
7. Add batch operation tests
8. Add business logic tests (upsertOrDelete)
9. Add capacity validation tests
10. Add complex scenario tests
11. Run tests: `flutter test test/integration/assignment_integration_test.dart`
12. Update README.md

## Estimated Effort

- **File creation:** ~400-500 lines
- **Test count:** ~20-25 tests
- **Time:** ~2-3 hours
- **Complexity:** High (requires item + container setup, multi-entity interactions)

## Related Files

- Template: `test/integration/item_crud_integration_test.dart`
- Model: `lib/models/assignment.dart`
- Repository: `lib/repositories/assignment_repository.dart`
- Mock: `lib/repositories/impl/mock/mock_assignment_repository.dart`
- Helpers: `test/helpers/test_helpers.dart`
- Dependencies: Item and Container models/repositories

## Success Criteria

- ✅ All tests pass
- ✅ Tests cover assign, update, remove operations
- ✅ Query operations validated (by item, by container, by IDs)
- ✅ Batch operations tested
- ✅ Business logic (upsertOrDelete) validated
- ⚠️ Capacity validation implemented (basic coverage, no over-assignment validation yet)
- ✅ Stream emissions verified (basic stream availability tested)
- ⚠️ Edge cases handled (basic cases covered, advanced validation deferred)
- ⚠️ Complex scenarios (move, redistribute) tested (deferred to future work)
- ✅ No UI dependencies

## Implementation Summary

**Completed (13 tests):**
- Basic CRUD: Create, read, update, delete assignments
- Query Operations: Get by container, by item, by item+container IDs
- Business Logic: upsertOrDeleteAssignment (count=0 triggers deletion)
- Batch Operations: Batch update/delete
- Stream Behavior: Stream availability and state consistency

**Deferred to Future Work:**
- Advanced capacity validation (over-assignment scenarios)
- Complex multi-container redistribution tests
- Detailed stream emission counting (single vs batch)
- Edge case validation (negative counts, non-existent entities)
- Performance testing with large datasets

**Rationale:** Core functionality is fully tested. Advanced scenarios can be added when business requirements are clarified or issues arise in production.

## Integration with Other Tests

After assignment tests are complete, consider:
1. **Cross-entity tests** - Create item → create container → assign → verify totals
2. **Work log tests** - Assignment changes should trigger work log entries
3. **UI integration tests** - Test assignment UI components
4. **Performance tests** - Batch operations with 100+ assignments

## Business Logic Notes

Document any business rules discovered:
- Can items be over-assigned?
- What happens when item.totalAmount is reduced?
- How are orphaned assignments handled?
- Container capacity constraints?
- Assignment audit trail requirements?
