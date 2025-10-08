# TODO: Container CRUD Integration Tests

This document outlines the plan for implementing integration tests for Container CRUD operations.

## Overview

Container tests should follow the same pattern as Item CRUD tests (see `test/integration/item_crud_integration_test.dart`).

**Target file:** `test/integration/container_crud_integration_test.dart`

## Container Model

**Location:** `lib/models/container_dao.dart`

**Key Fields:**
- Required: `id`, `number`, `name`, `sequentialBuild`, `isReady`, `toDeploy`
- Optional: `description`, `typeId`, `moduleDestinationId`, `currentLocationId`

**Related Models:**
- `SequentialBuild` enum (firstBuild, secondBuild, thirdBuild)
- References to: ContainerType, ModuleDestination, CurrentLocation

## Repository Interface

**Location:** `lib/repositories/container_repository.dart`

**Operations:**
- `upsertContainer(ContainerDao)` - Create or update
- `createContainer(ContainerDao)` - Create (alias)
- `updateContainer(ContainerDao)` - Update (alias)
- `deleteContainer(String id)` - Delete
- `getContainer(String id)` - Get by ID
- `watchContainers()` - Stream all containers
- `getContainersByType(String typeId)` - Filter by type
- `getContainersByLocation(String locationId)` - Filter by location
- `batchUpdateContainers(List<ContainerDao>)` - Batch update

## Mock Repository

**Location:** `lib/repositories/impl/mock/mock_container_repository.dart`

Already exists - review for completeness.

## Test Structure

Follow the pattern from `item_crud_integration_test.dart`:

```dart
void main() {
  group('Container CRUD Integration Tests', () {
    late MockContainerRepository mockRepo;

    setUp(() {
      mockRepo = MockContainerRepository();
      // Clear initial test data if any
    });

    tearDown(() {
      mockRepo.dispose();
    });

    group('Create Container', () {
      // Test 1: Create with required fields only
      // Test 2: Create with all optional fields populated
    });

    group('Update Container', () {
      // Test 1: Update ALL modifiable fields comprehensively
      // Test 2: Update specific field (e.g., isReady status)
      // Test 3: Update sequential build progression
    });

    group('Delete Container', () {
      // Test 1: Delete existing container
      // Test 2: Verify removal from stream
    });

    group('Query Operations', () {
      // Test 1: Get containers by type
      // Test 2: Get containers by location
    });

    group('Error Scenarios', () {
      // Test 1: Delete non-existent container
      // Test 2: Handle multiple rapid updates
    });

    group('Stream Operations', () {
      // Test 1: Emit on create
      // Test 2: Emit on update
      // Test 3: Emit on delete
    });
  });
}
```

## Test Cases

### 1. Create Tests

**Test: Create with required fields only**
```dart
final container = ContainerDao(
  id: 'test-container-1',
  number: 1,
  name: 'Test Container',
  sequentialBuild: SequentialBuild.firstBuild,
  isReady: false,
  toDeploy: false,
);
```

**Test: Create with all optional fields**
```dart
final container = ContainerDao(
  id: 'test-container-2',
  number: 2,
  name: 'Complete Container',
  description: 'Test container with all fields',
  typeId: 'euro-box',
  moduleDestinationId: 'module-1',
  currentLocationId: 'warehouse-a',
  sequentialBuild: SequentialBuild.firstBuild,
  isReady: true,
  toDeploy: true,
);
```

### 2. Update Tests

**Test: Update ALL modifiable fields**
Update these fields:
- `number` - Change container number
- `name` - Change name
- `description` - Add/update description
- `typeId` - Change container type
- `moduleDestinationId` - Change destination
- `currentLocationId` - Change location
- `sequentialBuild` - Progress from firstBuild → secondBuild → thirdBuild
- `isReady` - Toggle ready status
- `toDeploy` - Toggle deploy status

**Test: Sequential build progression**
Verify progression: firstBuild → secondBuild → thirdBuild

### 3. Delete Tests

- Delete existing container
- Verify ContainerException thrown for non-existent container
- Verify stream emission after deletion

### 4. Query Tests

**Get by type:**
- Create 3 containers: 2 with typeId='euro-box', 1 with typeId='pallet'
- Query by 'euro-box', expect 2 results
- Query by 'pallet', expect 1 result
- Query by 'non-existent', expect 0 results

**Get by location:**
- Create 3 containers: 2 at 'warehouse-a', 1 at 'warehouse-b'
- Query by 'warehouse-a', expect 2 results
- Query by 'warehouse-b', expect 1 result

### 5. Stream Tests

- Verify stream emits on create
- Verify stream emits on update
- Verify stream emits on delete
- Verify stream emits correct container count

## Helper Functions Needed

Add to `test/helpers/test_helpers.dart` if not already present:

```dart
/// Creates a test ContainerDao instance
ContainerDao createTestContainer({
  String id = 'test-container',
  int number = 1,
  String name = 'Test Container',
  String? description,
  String? typeId,
  String? moduleDestinationId,
  String? currentLocationId,
  SequentialBuild sequentialBuild = SequentialBuild.firstBuild,
  bool isReady = false,
  bool toDeploy = false,
});
```

**Note:** This function already exists - verify it covers all parameters.

## Implementation Steps

1. Review `test/integration/item_crud_integration_test.dart` as template
2. Review `MockContainerRepository` implementation
3. Create `test/integration/container_crud_integration_test.dart`
4. Implement test groups following the structure above
5. Run tests: `flutter test test/integration/container_crud_integration_test.dart`
6. Update README.md to list new test file

## Estimated Effort

- **File creation:** ~250 lines
- **Test count:** ~12-15 tests
- **Time:** ~60-90 minutes
- **Complexity:** Medium (similar to item tests)

## Related Files

- Template: `test/integration/item_crud_integration_test.dart`
- Model: `lib/models/container_dao.dart`
- Repository: `lib/repositories/container_repository.dart`
- Mock: `lib/repositories/impl/mock/mock_container_repository.dart`
- Helpers: `test/helpers/test_helpers.dart`

## Success Criteria

- ✅ All tests pass
- ✅ Tests cover create, update, delete operations
- ✅ Comprehensive update test covers ALL modifiable fields
- ✅ Query operations (by type, by location) validated
- ✅ Stream emissions verified
- ✅ Error scenarios handled
- ✅ Follows same pattern as item tests
- ✅ No UI dependencies (pure repository tests)

## Future Enhancements

After basic CRUD tests are working:
1. Test batch operations (`batchUpdateContainers`)
2. Test container capacity constraints (if applicable)
3. Test relationships with assignments (containers with items)
4. Test container type validation
5. Test location validation
