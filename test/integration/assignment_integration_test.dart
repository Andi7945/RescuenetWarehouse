import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_assignment_repository.dart';

/// Helper to create test items
Item createTestItem({
  String id = 'test-item',
  String name = 'Test Item',
  double rescueNetId = 1001.0,
  int totalAmount = 10,
  double weight = 1.5,
  String description = 'Test description',
  OperationalStatus status = OperationalStatus.deployable,
}) {
  return Item(
    id: id,
    name: name,
    rescueNetId: rescueNetId,
    totalAmount: totalAmount,
    weight: weight,
    description: description,
    operationalStatus: status,
  );
}

/// Helper to create test containers
ContainerDao createTestContainer({
  String id = 'test-container',
  String name = 'Test Container',
  int number = 1,
  SequentialBuild sequentialBuild = SequentialBuild.firstBuild,
  bool isReady = false,
  bool toDeploy = false,
}) {
  return ContainerDao(
    id: id,
    number: number,
    name: name,
    sequentialBuild: sequentialBuild,
    isReady: isReady,
    toDeploy: toDeploy,
  );
}

/// Helper to create test assignments
Assignment createTestAssignment({
  String id = 'test-assignment',
  String itemId = 'test-item',
  String containerId = 'test-container',
  int count = 5,
}) {
  return Assignment(
    id: id,
    itemId: itemId,
    containerId: containerId,
    count: count,
  );
}

/// Integration tests for Assignment CRUD operations.
/// Tests the full lifecycle of assignment management through the repository layer.
void main() {
  group('Assignment Integration Tests', () {
    late MockAssignmentRepository mockRepo;
    late Item testItem;
    late ContainerDao testContainer;

    setUp(() {
      mockRepo = MockAssignmentRepository();
      mockRepo.clearAll(); // Start with clean slate
      testItem = createTestItem(id: 'item-1', totalAmount: 100);
      testContainer = createTestContainer(id: 'container-1');
    });

    tearDown(() {
      mockRepo.dispose();
    });

    group('Basic CRUD Operations', () {
      test(
        'should create new assignment with valid item and container IDs',
        () async {
          // Arrange
          final newAssignment = Assignment(
            id: 'assignment-001',
            itemId: testItem.id,
            containerId: testContainer.id,
            count: 25,
          );

          // Act
          await mockRepo.upsertAssignment(newAssignment);
          final retrieved = await mockRepo.getAssignment('assignment-001');

          // Assert
          expect(retrieved, isNotNull);
          expect(retrieved?.id, equals('assignment-001'));
          expect(retrieved?.itemId, equals(testItem.id));
          expect(retrieved?.containerId, equals(testContainer.id));
          expect(retrieved?.count, equals(25));
        },
      );

      test('should read assignment by ID', () async {
        // Arrange
        final assignment = createTestAssignment(
          id: 'read-test-001',
          itemId: 'item-alpha',
          containerId: 'container-beta',
          count: 15,
        );
        await mockRepo.upsertAssignment(assignment);

        // Act
        final retrieved = await mockRepo.getAssignment('read-test-001');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved?.id, equals('read-test-001'));
        expect(retrieved?.itemId, equals('item-alpha'));
        expect(retrieved?.containerId, equals('container-beta'));
        expect(retrieved?.count, equals(15));
      });

      test('should update assignment count via upsert', () async {
        // Arrange
        final original = createTestAssignment(
          id: 'update-test-001',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 10,
        );
        await mockRepo.upsertAssignment(original);

        // Act - Update count from 10 to 50
        final updated = original.copyWith(count: 50);
        await mockRepo.upsertAssignment(updated);
        final retrieved = await mockRepo.getAssignment('update-test-001');

        // Assert
        expect(retrieved?.count, equals(50));
        expect(retrieved?.itemId, equals('item-1'));
        expect(retrieved?.containerId, equals('container-1'));
      });

      test('should delete assignment successfully', () async {
        // Arrange
        final assignment = createTestAssignment(id: 'delete-test-001');
        await mockRepo.upsertAssignment(assignment);

        // Verify exists before deletion
        final beforeDelete = await mockRepo.getAssignment('delete-test-001');
        expect(beforeDelete, isNotNull);

        // Act
        await mockRepo.deleteAssignment('delete-test-001');

        // Assert
        final afterDelete = await mockRepo.getAssignment('delete-test-001');
        expect(afterDelete, isNull);
      });
    });

    group('Query Operations', () {
      test('should get all assignments for specific container', () async {
        // Arrange
        final container1Assignments = [
          createTestAssignment(
            id: 'assign-1',
            itemId: 'item-1',
            containerId: 'container-alpha',
            count: 10,
          ),
          createTestAssignment(
            id: 'assign-2',
            itemId: 'item-2',
            containerId: 'container-alpha',
            count: 20,
          ),
          createTestAssignment(
            id: 'assign-3',
            itemId: 'item-3',
            containerId: 'container-beta',
            count: 5,
          ),
        ];

        for (final assignment in container1Assignments) {
          await mockRepo.upsertAssignment(assignment);
        }

        // Act
        final containerAssignments = await mockRepo.getAssignmentsForContainer(
          'container-alpha',
        );

        // Assert
        expect(containerAssignments, hasLength(2));
        expect(
          containerAssignments.every((a) => a.containerId == 'container-alpha'),
          isTrue,
        );
        expect(
          containerAssignments.map((a) => a.id),
          containsAll(['assign-1', 'assign-2']),
        );
      });

      test('should get all assignments for specific item', () async {
        // Arrange
        final itemAssignments = [
          createTestAssignment(
            id: 'assign-1',
            itemId: 'item-alpha',
            containerId: 'container-1',
            count: 15,
          ),
          createTestAssignment(
            id: 'assign-2',
            itemId: 'item-alpha',
            containerId: 'container-2',
            count: 25,
          ),
          createTestAssignment(
            id: 'assign-3',
            itemId: 'item-beta',
            containerId: 'container-1',
            count: 5,
          ),
        ];

        for (final assignment in itemAssignments) {
          await mockRepo.upsertAssignment(assignment);
        }

        // Act
        final assignments = await mockRepo.getAssignmentsForItem('item-alpha');

        // Assert
        expect(assignments, hasLength(2));
        expect(assignments.every((a) => a.itemId == 'item-alpha'), isTrue);
        expect(
          assignments.map((a) => a.id),
          containsAll(['assign-1', 'assign-2']),
        );
      });

      test('should get assignment by itemId and containerId', () async {
        // Arrange
        final assignments = [
          createTestAssignment(
            id: 'assign-1',
            itemId: 'item-x',
            containerId: 'container-y',
            count: 30,
          ),
          createTestAssignment(
            id: 'assign-2',
            itemId: 'item-x',
            containerId: 'container-z',
            count: 40,
          ),
          createTestAssignment(
            id: 'assign-3',
            itemId: 'item-w',
            containerId: 'container-y',
            count: 50,
          ),
        ];

        for (final assignment in assignments) {
          await mockRepo.upsertAssignment(assignment);
        }

        // Act
        final found = await mockRepo.getAssignmentByIds(
          'item-x',
          'container-y',
        );

        // Assert
        expect(found, isNotNull);
        expect(found?.id, equals('assign-1'));
        expect(found?.itemId, equals('item-x'));
        expect(found?.containerId, equals('container-y'));
        expect(found?.count, equals(30));
      });
    });

    group('Business Logic', () {
      test('should upsert assignment when count > 0', () async {
        // Arrange
        final assignment = createTestAssignment(
          id: 'upsert-test-001',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 20,
        );

        // Act
        await mockRepo.upsertAssignment(assignment);
        final retrieved = await mockRepo.getAssignment('upsert-test-001');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved?.count, equals(20));
      });

      test('should delete assignment', () async {
        // Arrange
        final assignment = createTestAssignment(
          id: 'delete-zero-001',
          itemId: 'item-1',
          containerId: 'container-1',
          count: 15,
        );
        await mockRepo.upsertAssignment(assignment);

        // Verify exists
        final before = await mockRepo.getAssignment('delete-zero-001');
        expect(before, isNotNull);

        // Act - Delete assignment
        await mockRepo.deleteAssignment('delete-zero-001');

        // Assert
        final after = await mockRepo.getAssignment('delete-zero-001');
        expect(after, isNull);
      });
    });

    group('Batch Operations', () {
      test('should batch update multiple assignments', () async {
        // Arrange
        final assignments = [
          createTestAssignment(
            id: 'batch-1',
            itemId: 'item-1',
            containerId: 'container-1',
            count: 10,
          ),
          createTestAssignment(
            id: 'batch-2',
            itemId: 'item-2',
            containerId: 'container-2',
            count: 20,
          ),
          createTestAssignment(
            id: 'batch-3',
            itemId: 'item-3',
            containerId: 'container-3',
            count: 30,
          ),
        ];

        // Act
        await mockRepo.batchUpdateAssignments(assignments);

        // Assert - Verify all were created
        final retrieved1 = await mockRepo.getAssignment('batch-1');
        final retrieved2 = await mockRepo.getAssignment('batch-2');
        final retrieved3 = await mockRepo.getAssignment('batch-3');

        expect(retrieved1?.count, equals(10));
        expect(retrieved2?.count, equals(20));
        expect(retrieved3?.count, equals(30));
      });

      test('should batch delete multiple assignments', () async {
        // Arrange
        final assignments = [
          createTestAssignment(id: 'batch-del-1'),
          createTestAssignment(id: 'batch-del-2'),
          createTestAssignment(id: 'batch-del-3'),
        ];

        for (final assignment in assignments) {
          await mockRepo.upsertAssignment(assignment);
        }

        // Verify all exist
        expect(await mockRepo.getAssignment('batch-del-1'), isNotNull);
        expect(await mockRepo.getAssignment('batch-del-2'), isNotNull);
        expect(await mockRepo.getAssignment('batch-del-3'), isNotNull);

        // Act
        await mockRepo.batchDeleteAssignments([
          'batch-del-1',
          'batch-del-2',
          'batch-del-3',
        ]);

        // Assert
        expect(await mockRepo.getAssignment('batch-del-1'), isNull);
        expect(await mockRepo.getAssignment('batch-del-2'), isNull);
        expect(await mockRepo.getAssignment('batch-del-3'), isNull);
      });
    });

    group('Stream Behavior', () {
      test('should provide stream of all assignments', () async {
        // Arrange
        final assignment1 = createTestAssignment(id: 'stream-1', count: 10);
        final assignment2 = createTestAssignment(id: 'stream-2', count: 20);

        // Act
        await mockRepo.upsertAssignment(assignment1);
        await mockRepo.upsertAssignment(assignment2);

        // Assert - Stream is available and not null
        final stream = mockRepo.watchAssignments();
        expect(stream, isNotNull);
      });

      test('should reflect deletions in repository state', () async {
        // Arrange
        final assignment = createTestAssignment(id: 'stream-delete-001');
        await mockRepo.upsertAssignment(assignment);

        // Verify exists
        expect(await mockRepo.getAssignment('stream-delete-001'), isNotNull);

        // Act
        await mockRepo.deleteAssignment('stream-delete-001');

        // Assert - Deletion reflected in repository
        expect(await mockRepo.getAssignment('stream-delete-001'), isNull);
        expect(mockRepo.assignmentCount, equals(0));
      });
    });
  });
}
