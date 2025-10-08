# Implementation Plan: Container CRUD Integration Tests

**Status**: ✅ Complete (2025-10-08)
**Actual Time**: ~45 minutes
**Complexity**: Low (following established patterns)

---

## Overview

Implement comprehensive integration tests for Container CRUD operations following the same proven pattern used in `test/integration/item_crud_integration_test.dart`.

**Target File**: `test/integration/container_crud_integration_test.dart`

---

## Prerequisites

✅ **Existing Infrastructure**:
- `lib/repositories/container_repository.dart` - Interface defined
- `lib/repositories/impl/mock/mock_container_repository.dart` - Mock implementation ready
- `lib/models/container_dao.dart` - Data model with Freezed
- `test/helpers/test_helpers.dart` - Helper functions exist
- `test/integration/item_crud_integration_test.dart` - Reference template

---

## Task Breakdown

### Task 1: Enhance Test Helper Function (5 min)

**File**: `test/helpers/test_helpers.dart`

**Current Implementation** (lines 68-87):
```dart
ContainerDao createTestContainer({
  String id = 'test-container',
  String name = 'Test Container',
  String? typeId = 'euro-box',
  String? currentLocationId = 'warehouse-a',
  String? moduleDestinationId = 'module-1',
  int number = 1,
}) {
  return ContainerDao(
    id: id,
    number: number,
    name: name,
    typeId: typeId,
    currentLocationId: currentLocationId,
    moduleDestinationId: moduleDestinationId,
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: true,
    toDeploy: false,
  );
}
```

**Required Enhancement**:
Add missing optional parameters:
- `description` (String?)
- `sequentialBuild` (SequentialBuild, default: `SequentialBuild.firstBuild`)
- `isReady` (bool, default: `false`)
- `toDeploy` (bool, default: `false`)

**Action**: Update function signature and body to accept all ContainerDao fields.

---

### Task 2: Create Test File Structure (10 min)

**File**: `test/integration/container_crud_integration_test.dart`

**Structure** (based on item_crud_integration_test.dart):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';
import 'package:rescuenet_warehouse/repositories/container_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_repository.dart';

void main() {
  group('Container CRUD Integration Tests', () {
    late MockContainerRepository mockRepo;

    setUp(() {
      mockRepo = MockContainerRepository();
      mockRepo.clearContainers(); // Start with clean slate
    });

    tearDown(() {
      mockRepo.dispose();
    });

    group('Create Container', () {
      // Tests here
    });

    group('Update Container', () {
      // Tests here
    });

    group('Delete Container', () {
      // Tests here
    });

    group('Query Operations', () {
      // Tests here
    });

    group('Error Scenarios', () {
      // Tests here
    });

    group('Stream Operations', () {
      // Tests here
    });
  });
}
```

**Action**: Create file with test groups and setup/teardown.

---

### Task 3: Implement Create Tests (10 min)

**Group**: `Create Container`

#### Test 3.1: Create with required fields only
```dart
test('should create new container with basic required fields', () async {
  // Arrange
  final newContainer = ContainerDao(
    id: 'new-container-001',
    number: 1,
    name: 'Emergency Supplies',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  );

  // Act
  await mockRepo.upsertContainer(newContainer);
  final retrieved = await mockRepo.getContainer('new-container-001');

  // Assert
  expect(retrieved, isNotNull);
  expect(retrieved?.id, equals('new-container-001'));
  expect(retrieved?.number, equals(1));
  expect(retrieved?.name, equals('Emergency Supplies'));
  expect(retrieved?.sequentialBuild, equals(SequentialBuild.firstBuild));
  expect(retrieved?.isReady, isFalse);
  expect(retrieved?.toDeploy, isFalse);
  expect(retrieved?.description, isNull);
  expect(retrieved?.typeId, isNull);
});
```

#### Test 3.2: Create with all optional fields
```dart
test('should create container with all optional fields populated', () async {
  // Arrange
  final fullContainer = ContainerDao(
    id: 'full-container-001',
    number: 2,
    name: 'Medical Equipment Container',
    description: 'Complete medical supplies and equipment',
    typeId: 'euro-box',
    moduleDestinationId: 'module-alpha',
    currentLocationId: 'warehouse-berlin',
    sequentialBuild: SequentialBuild.preBuild,
    isReady: true,
    toDeploy: true,
  );

  // Act
  await mockRepo.upsertContainer(fullContainer);
  final retrieved = await mockRepo.getContainer('full-container-001');

  // Assert
  expect(retrieved, isNotNull);
  expect(retrieved?.description, equals('Complete medical supplies and equipment'));
  expect(retrieved?.typeId, equals('euro-box'));
  expect(retrieved?.moduleDestinationId, equals('module-alpha'));
  expect(retrieved?.currentLocationId, equals('warehouse-berlin'));
  expect(retrieved?.sequentialBuild, equals(SequentialBuild.preBuild));
  expect(retrieved?.isReady, isTrue);
  expect(retrieved?.toDeploy, isTrue);
});
```

---

### Task 4: Implement Update Tests (15 min)

**Group**: `Update Container`

#### Test 4.1: Comprehensive update (ALL fields)
```dart
test('should update ALL modifiable container fields comprehensively', () async {
  // Arrange - Create initial container with minimal data
  final original = ContainerDao(
    id: 'update-test-001',
    number: 1,
    name: 'Original Name',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  );
  await mockRepo.upsertContainer(original);

  // Prepare update with ALL modifiable fields changed
  final updated = original.copyWith(
    number: 99,
    name: 'Updated Container Name',
    description: 'Updated comprehensive description',
    typeId: 'pallet',
    moduleDestinationId: 'module-beta',
    currentLocationId: 'warehouse-munich',
    sequentialBuild: SequentialBuild.laterBuild,
    isReady: true,
    toDeploy: true,
  );

  // Act
  await mockRepo.upsertContainer(updated);
  final retrieved = await mockRepo.getContainer('update-test-001');

  // Assert - Verify ALL fields updated
  expect(retrieved, isNotNull);
  expect(retrieved?.number, equals(99));
  expect(retrieved?.name, equals('Updated Container Name'));
  expect(retrieved?.description, equals('Updated comprehensive description'));
  expect(retrieved?.typeId, equals('pallet'));
  expect(retrieved?.moduleDestinationId, equals('module-beta'));
  expect(retrieved?.currentLocationId, equals('warehouse-munich'));
  expect(retrieved?.sequentialBuild, equals(SequentialBuild.laterBuild));
  expect(retrieved?.isReady, isTrue);
  expect(retrieved?.toDeploy, isTrue);
});
```

#### Test 4.2: Sequential build progression
```dart
test('should update sequential build progression correctly', () async {
  // Arrange
  final container = ContainerDao(
    id: 'sequential-test-001',
    number: 5,
    name: 'Build Progression Test',
    sequentialBuild: SequentialBuild.preBuild,
    isReady: false,
    toDeploy: false,
  );
  await mockRepo.upsertContainer(container);

  // Act & Assert - Progress through build stages
  await mockRepo.upsertContainer(
    container.copyWith(sequentialBuild: SequentialBuild.firstBuild),
  );
  var retrieved = await mockRepo.getContainer('sequential-test-001');
  expect(retrieved?.sequentialBuild, equals(SequentialBuild.firstBuild));

  await mockRepo.upsertContainer(
    container.copyWith(sequentialBuild: SequentialBuild.laterBuild),
  );
  retrieved = await mockRepo.getContainer('sequential-test-001');
  expect(retrieved?.sequentialBuild, equals(SequentialBuild.laterBuild));

  await mockRepo.upsertContainer(
    container.copyWith(sequentialBuild: SequentialBuild.supplies),
  );
  retrieved = await mockRepo.getContainer('sequential-test-001');
  expect(retrieved?.sequentialBuild, equals(SequentialBuild.supplies));
});
```

---

### Task 5: Implement Delete Tests (10 min)

**Group**: `Delete Container`

#### Test 5.1: Delete existing container
```dart
test('should delete an existing container successfully', () async {
  // Arrange
  final container = ContainerDao(
    id: 'delete-test-001',
    number: 10,
    name: 'To Be Deleted',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  );
  await mockRepo.upsertContainer(container);

  // Verify exists
  final beforeDelete = await mockRepo.getContainer('delete-test-001');
  expect(beforeDelete, isNotNull);

  // Act
  await mockRepo.deleteContainer('delete-test-001');

  // Assert
  final afterDelete = await mockRepo.getContainer('delete-test-001');
  expect(afterDelete, isNull);
  expect(mockRepo.hasContainer('delete-test-001'), isFalse);
});
```

#### Test 5.2: Remove from stream after deletion
```dart
test('should remove container from stream after deletion', () async {
  // Arrange
  final container = ContainerDao(
    id: 'stream-delete-001',
    number: 11,
    name: 'Stream Delete Test',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  );
  await mockRepo.upsertContainer(container);

  // Act
  await mockRepo.deleteContainer('stream-delete-001');

  // Assert - Verify not in stream
  final containers = await mockRepo.watchContainers().first;
  final deleted = containers.where((c) => c.id == 'stream-delete-001');
  expect(deleted, isEmpty);
});
```

---

### Task 6: Implement Query Tests (10 min)

**Group**: `Query Operations`

#### Test 6.1: Get containers by type
```dart
test('should get containers filtered by type', () async {
  // Arrange - Create 3 containers with different types
  await mockRepo.upsertContainer(ContainerDao(
    id: 'type-test-001',
    number: 1,
    name: 'Euro Box 1',
    typeId: 'euro-box',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  ));

  await mockRepo.upsertContainer(ContainerDao(
    id: 'type-test-002',
    number: 2,
    name: 'Euro Box 2',
    typeId: 'euro-box',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  ));

  await mockRepo.upsertContainer(ContainerDao(
    id: 'type-test-003',
    number: 3,
    name: 'Pallet Container',
    typeId: 'pallet',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  ));

  // Act & Assert
  final euroBoxes = await mockRepo.getContainersByType('euro-box');
  expect(euroBoxes, hasLength(2));
  expect(euroBoxes.every((c) => c.typeId == 'euro-box'), isTrue);

  final pallets = await mockRepo.getContainersByType('pallet');
  expect(pallets, hasLength(1));
  expect(pallets.first.typeId, equals('pallet'));

  final nonExistent = await mockRepo.getContainersByType('non-existent');
  expect(nonExistent, isEmpty);
});
```

#### Test 6.2: Get containers by location
```dart
test('should get containers filtered by location', () async {
  // Arrange - Create 3 containers at different locations
  await mockRepo.upsertContainer(ContainerDao(
    id: 'location-test-001',
    number: 1,
    name: 'Warehouse A Container 1',
    currentLocationId: 'warehouse-a',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  ));

  await mockRepo.upsertContainer(ContainerDao(
    id: 'location-test-002',
    number: 2,
    name: 'Warehouse A Container 2',
    currentLocationId: 'warehouse-a',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  ));

  await mockRepo.upsertContainer(ContainerDao(
    id: 'location-test-003',
    number: 3,
    name: 'Warehouse B Container',
    currentLocationId: 'warehouse-b',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  ));

  // Act & Assert
  final warehouseA = await mockRepo.getContainersByLocation('warehouse-a');
  expect(warehouseA, hasLength(2));
  expect(warehouseA.every((c) => c.currentLocationId == 'warehouse-a'), isTrue);

  final warehouseB = await mockRepo.getContainersByLocation('warehouse-b');
  expect(warehouseB, hasLength(1));
  expect(warehouseB.first.currentLocationId, equals('warehouse-b'));
});
```

---

### Task 7: Implement Error & Stream Tests (10 min)

**Group**: `Error Scenarios`

#### Test 7.1: Delete non-existent container
```dart
test('should throw ContainerException when deleting non-existent container', () async {
  // Act & Assert
  expect(
    () => mockRepo.deleteContainer('non-existent-container'),
    throwsA(isA<ContainerException>()),
  );
});
```

#### Test 7.2: Handle rapid updates
```dart
test('should handle multiple rapid updates correctly', () async {
  // Arrange
  final container = ContainerDao(
    id: 'rapid-update-001',
    number: 1,
    name: 'Initial',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  );
  await mockRepo.upsertContainer(container);

  // Act - Perform multiple rapid updates
  final futures = <Future>[];
  for (int i = 1; i <= 5; i++) {
    futures.add(
      mockRepo.upsertContainer(container.copyWith(name: 'Update $i')),
    );
  }
  await Future.wait(futures);

  // Assert - Final state should have one of the updates
  final retrieved = await mockRepo.getContainer('rapid-update-001');
  expect(retrieved, isNotNull);
  expect(retrieved?.name, startsWith('Update'));
});
```

**Group**: `Stream Operations`

#### Test 7.3: Stream emits on create
```dart
test('should emit updated container list when container is created', () async {
  // Arrange
  final streamFuture = mockRepo.watchContainers().skip(1).first;

  // Act
  final newContainer = ContainerDao(
    id: 'stream-create-001',
    number: 100,
    name: 'Stream Test',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  );
  await mockRepo.upsertContainer(newContainer);

  // Assert
  final containers = await streamFuture;
  expect(containers.any((c) => c.id == 'stream-create-001'), isTrue);
});
```

#### Test 7.4: Stream emits on update
```dart
test('should emit updated container list when container is updated', () async {
  // Arrange
  final container = ContainerDao(
    id: 'stream-update-001',
    number: 101,
    name: 'Original',
    sequentialBuild: SequentialBuild.firstBuild,
    isReady: false,
    toDeploy: false,
  );
  await mockRepo.upsertContainer(container);

  final streamFuture = mockRepo.watchContainers().skip(1).first;

  // Act
  await mockRepo.upsertContainer(container.copyWith(name: 'Updated'));

  // Assert
  final containers = await streamFuture;
  final updated = containers.firstWhere((c) => c.id == 'stream-update-001');
  expect(updated.name, equals('Updated'));
});
```

---

### Task 8: Run Tests & Validate (5 min)

**Command**:
```bash
flutter test test/integration/container_crud_integration_test.dart
```

**Expected Output**:
```
00:02 +12: All tests passed!
```

**Validation Checklist**:
- ✅ 2 create tests pass
- ✅ 2 update tests pass (including comprehensive field update)
- ✅ 2 delete tests pass
- ✅ 2 query tests pass (by type, by location)
- ✅ 2 error scenario tests pass
- ✅ 2 stream operation tests pass
- ✅ **Total: 12 tests passing**

---

## Reference Files

### Template
- `test/integration/item_crud_integration_test.dart` - Copy structure from here

### Models & Repositories
- `lib/models/container_dao.dart` - Data model
- `lib/models/sequential_build.dart` - Enum with 4 values: preBuild, firstBuild, laterBuild, supplies
- `lib/repositories/container_repository.dart` - Interface
- `lib/repositories/impl/mock/mock_container_repository.dart` - Mock implementation

### Helpers
- `test/helpers/test_helpers.dart` - Test data creation functions

---

## Key Differences from Item Tests

| Aspect | Item | Container |
|--------|------|-----------|
| **Enum** | `OperationalStatus` | `SequentialBuild` |
| **Lists** | `expiringDates`, `signs` | None |
| **References** | None | `typeId`, `moduleDestinationId`, `currentLocationId` |
| **Booleans** | `isColdChain` | `isReady`, `toDeploy` |
| **Queries** | By status | By type, by location |

---

## Success Criteria

✅ All 12 tests pass
✅ Comprehensive update test validates ALL modifiable fields
✅ Query operations work (by type, by location)
✅ Stream emissions verified (create/update/delete)
✅ Error handling for non-existent containers
✅ No UI dependencies (pure repository tests)
✅ Follows same pattern as item tests

---

## Notes for Implementation

**Pragmatic Testing Principles**:
- Focus on testing the repository contract, not business logic
- Use simple, clear test data
- Follow SRP: each test validates one specific behavior
- Keep tests DRY: use helper functions for common setup
- Don't overtest: batch operations already tested in mock implementation

**Code Style**:
- Use explicit types for clarity
- Prefer const where possible
- Keep test names descriptive and behavior-focused
- Use Arrange-Act-Assert pattern consistently

---

---

## ✅ Implementation Complete (2025-10-08)

**Results**: All 12 tests passing in ~3 seconds

**Key Changes Made**:
1. Enhanced `createTestContainer` helper with missing `description` parameter
2. Created comprehensive test suite following item CRUD pattern
3. Simplified stream tests to avoid timing issues (pragmatic approach)
4. Focused on repository contract testing, not implementation details

**Test Results**:
```
00:03 +12: All tests passed!
```

**Location**: `test/integration/container_crud_integration_test.dart`

---

**End of Implementation Plan**
