import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/assignment_repository.dart';
import 'package:rescuenet_warehouse/repositories/work_log_repository.dart';
import 'package:rescuenet_warehouse/services/assignment/assignment_service.dart';

void main() {
  group('AssignmentService', () {
    late MockAssignmentRepositoryForService assignmentRepo;
    late MockWorkLogRepositoryForService workLogRepo;
    late AssignmentService service;
    const testUser = 'TestUser';

    setUp(() {
      assignmentRepo = MockAssignmentRepositoryForService();
      workLogRepo = MockWorkLogRepositoryForService();
      service = AssignmentService(
        assignmentRepository: assignmentRepo,
        workLogRepository: workLogRepo,
        currentUser: testUser,
      );
    });

    group('updateAssignment', () {
      const itemId = 'item1';
      const containerId = 'container1';

      test('creates new assignment when none exists', () async {
        // Arrange - no existing assignment
        assignmentRepo.setExistingAssignment(null);

        // Act
        final result = await service.updateAssignment(
          itemId: itemId,
          containerId: containerId,
          newAmount: 5,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.itemId, equals(itemId));
        expect(result.containerId, equals(containerId));
        expect(result.count, equals(5));

        // Verify assignment was upserted
        expect(assignmentRepo.upsertedAssignments.length, equals(1));
        expect(assignmentRepo.upsertedAssignments.first.count, equals(5));

        // Verify work log was created with positive delta
        expect(workLogRepo.workLogs.length, equals(1));
        expect(workLogRepo.workLogs.first.itemId, equals(itemId));
        expect(workLogRepo.workLogs.first.containerId, equals(containerId));
        expect(workLogRepo.workLogs.first.count, equals(5)); // Delta: 0 -> 5
        expect(workLogRepo.workLogs.first.user, equals(testUser));
      });

      test('updates existing assignment', () async {
        // Arrange - existing assignment with count 3
        final existing = Assignment(
          id: 'assign1',
          itemId: itemId,
          containerId: containerId,
          count: 3,
        );
        assignmentRepo.setExistingAssignment(existing);

        // Act
        final result = await service.updateAssignment(
          itemId: itemId,
          containerId: containerId,
          newAmount: 8,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('assign1')); // Same ID
        expect(result.count, equals(8));

        // Verify assignment was updated
        expect(assignmentRepo.upsertedAssignments.length, equals(1));
        expect(assignmentRepo.upsertedAssignments.first.count, equals(8));

        // Verify work log shows delta of +5
        expect(workLogRepo.workLogs.length, equals(1));
        expect(workLogRepo.workLogs.first.count, equals(5)); // Delta: 3 -> 8
      });

      test('deletes assignment when newAmount is 0', () async {
        // Arrange - existing assignment
        final existing = Assignment(
          id: 'assign1',
          itemId: itemId,
          containerId: containerId,
          count: 7,
        );
        assignmentRepo.setExistingAssignment(existing);

        // Act
        final result = await service.updateAssignment(
          itemId: itemId,
          containerId: containerId,
          newAmount: 0,
        );

        // Assert
        expect(result, isNull); // Deleted assignments return null

        // Verify assignment was deleted
        expect(assignmentRepo.deletedIds.length, equals(1));
        expect(assignmentRepo.deletedIds.first, equals('assign1'));

        // Verify work log shows negative delta
        expect(workLogRepo.workLogs.length, equals(1));
        expect(workLogRepo.workLogs.first.count, equals(-7)); // Delta: 7 -> 0
      });

      test('returns early with no changes when delta is 0', () async {
        // Arrange - existing assignment with count 5
        final existing = Assignment(
          id: 'assign1',
          itemId: itemId,
          containerId: containerId,
          count: 5,
        );
        assignmentRepo.setExistingAssignment(existing);

        // Act
        final result = await service.updateAssignment(
          itemId: itemId,
          containerId: containerId,
          newAmount: 5, // Same amount
        );

        // Assert
        expect(result, equals(existing));

        // Verify no repository calls were made
        expect(assignmentRepo.upsertedAssignments.isEmpty, isTrue);
        expect(assignmentRepo.deletedIds.isEmpty, isTrue);

        // Verify no work log was created
        expect(workLogRepo.workLogs.isEmpty, isTrue);
      });

      test(
        'does not delete when newAmount is 0 but no existing assignment',
        () async {
          // Arrange - no existing assignment
          assignmentRepo.setExistingAssignment(null);

          // Act
          final result = await service.updateAssignment(
            itemId: itemId,
            containerId: containerId,
            newAmount: 0,
          );

          // Assert
          expect(result, isNull);

          // Verify no delete call was made (nothing to delete)
          expect(assignmentRepo.deletedIds.isEmpty, isTrue);

          // No work log should be created since delta is 0 (null -> 0 = no-op)
          expect(workLogRepo.workLogs.isEmpty, isTrue);
        },
      );
    });

    group('createAssignment', () {
      const itemId = 'item1';
      const containerId = 'container1';

      test('creates assignment successfully', () async {
        // Arrange - no existing assignment
        assignmentRepo.setExistingAssignment(null);

        // Act
        final result = await service.createAssignment(
          itemId: itemId,
          containerId: containerId,
          initialCount: 10,
        );

        // Assert
        expect(result.itemId, equals(itemId));
        expect(result.containerId, equals(containerId));
        expect(result.count, equals(10));

        // Verify assignment was created
        expect(assignmentRepo.upsertedAssignments.length, equals(1));

        // Verify work log was created
        expect(workLogRepo.workLogs.length, equals(1));
        expect(workLogRepo.workLogs.first.count, equals(10));
      });

      test('throws StateError when assignment already exists', () async {
        // Arrange - existing assignment
        final existing = Assignment(
          id: 'assign1',
          itemId: itemId,
          containerId: containerId,
          count: 5,
        );
        assignmentRepo.setExistingAssignment(existing);

        // Act & Assert
        expect(
          () async => await service.createAssignment(
            itemId: itemId,
            containerId: containerId,
            initialCount: 10,
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Assignment already exists'),
            ),
          ),
        );

        // Verify no assignment was created
        expect(assignmentRepo.upsertedAssignments.isEmpty, isTrue);

        // Verify no work log was created
        expect(workLogRepo.workLogs.isEmpty, isTrue);
      });

      test('throws ArgumentError when initialCount is 0', () async {
        // Arrange
        assignmentRepo.setExistingAssignment(null);

        // Act & Assert
        expect(
          () async => await service.createAssignment(
            itemId: itemId,
            containerId: containerId,
            initialCount: 0,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Initial count must be greater than 0'),
            ),
          ),
        );
      });

      test('throws ArgumentError when initialCount is negative', () async {
        // Arrange
        assignmentRepo.setExistingAssignment(null);

        // Act & Assert
        expect(
          () async => await service.createAssignment(
            itemId: itemId,
            containerId: containerId,
            initialCount: -5,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('deleteAssignment', () {
      test('deletes assignment and creates negative work log', () async {
        // Act
        await service.deleteAssignment(
          assignmentId: 'assign1',
          itemId: 'item1',
          containerId: 'container1',
          currentCount: 7,
        );

        // Assert
        expect(assignmentRepo.deletedIds.length, equals(1));
        expect(assignmentRepo.deletedIds.first, equals('assign1'));

        // Verify work log was created with negative count
        expect(workLogRepo.workLogs.length, equals(1));
        expect(workLogRepo.workLogs.first.itemId, equals('item1'));
        expect(workLogRepo.workLogs.first.containerId, equals('container1'));
        expect(workLogRepo.workLogs.first.count, equals(-7));
        expect(workLogRepo.workLogs.first.user, equals(testUser));
      });

      test('handles deletion with count 0', () async {
        // Act
        await service.deleteAssignment(
          assignmentId: 'assign1',
          itemId: 'item1',
          containerId: 'container1',
          currentCount: 0,
        );

        // Assert
        expect(assignmentRepo.deletedIds.length, equals(1));

        // Work log should have count of 0
        expect(workLogRepo.workLogs.length, equals(1));
        expect(workLogRepo.workLogs.first.count, equals(0));
      });
    });

    group('batchUpdateAssignments', () {
      test('updates multiple assignments with work logs', () async {
        // Arrange
        final assignments = [
          Assignment(
            id: '1',
            itemId: 'item1',
            containerId: 'container1',
            count: 5,
          ),
          Assignment(
            id: '2',
            itemId: 'item2',
            containerId: 'container1',
            count: 3,
          ),
          Assignment(
            id: '3',
            itemId: 'item3',
            containerId: 'container2',
            count: 8,
          ),
        ];
        final deltas = [2, -1, 4]; // Changes for each assignment

        // Act
        await service.batchUpdateAssignments(
          assignments: assignments,
          deltas: deltas,
        );

        // Assert
        expect(assignmentRepo.batchUpdatedAssignments.length, equals(3));

        // Verify work logs created for all non-zero deltas
        expect(workLogRepo.workLogs.length, equals(3));
        expect(workLogRepo.workLogs[0].count, equals(2));
        expect(workLogRepo.workLogs[0].itemId, equals('item1'));
        expect(workLogRepo.workLogs[1].count, equals(-1));
        expect(workLogRepo.workLogs[1].itemId, equals('item2'));
        expect(workLogRepo.workLogs[2].count, equals(4));
        expect(workLogRepo.workLogs[2].itemId, equals('item3'));
      });

      test('filters out zero deltas from work logs', () async {
        // Arrange
        final assignments = [
          Assignment(
            id: '1',
            itemId: 'item1',
            containerId: 'container1',
            count: 5,
          ),
          Assignment(
            id: '2',
            itemId: 'item2',
            containerId: 'container1',
            count: 3,
          ),
        ];
        final deltas = [0, 5]; // First has no change

        // Act
        await service.batchUpdateAssignments(
          assignments: assignments,
          deltas: deltas,
        );

        // Assert
        expect(assignmentRepo.batchUpdatedAssignments.length, equals(2));

        // Only one work log should be created (second one with delta 5)
        expect(workLogRepo.workLogs.length, equals(1));
        expect(workLogRepo.workLogs.first.count, equals(5));
        expect(workLogRepo.workLogs.first.itemId, equals('item2'));
      });

      test(
        'throws ArgumentError when assignments and deltas length mismatch',
        () async {
          // Arrange
          final assignments = [
            Assignment(
              id: '1',
              itemId: 'item1',
              containerId: 'container1',
              count: 5,
            ),
          ];
          final deltas = [2, 3]; // More deltas than assignments

          // Act & Assert
          expect(
            () async => await service.batchUpdateAssignments(
              assignments: assignments,
              deltas: deltas,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Assignments and deltas must have same length'),
              ),
            ),
          );
        },
      );

      test('handles empty lists', () async {
        // Act
        await service.batchUpdateAssignments(assignments: [], deltas: []);

        // Assert
        expect(assignmentRepo.batchUpdatedAssignments.isEmpty, isTrue);
        expect(workLogRepo.workLogs.isEmpty, isTrue);
      });
    });
  });
}

/// Mock AssignmentRepository for testing
class MockAssignmentRepositoryForService implements AssignmentRepository {
  Assignment? _existingAssignment;
  final List<Assignment> upsertedAssignments = [];
  final List<String> deletedIds = [];
  final List<Assignment> batchUpdatedAssignments = [];

  void setExistingAssignment(Assignment? assignment) {
    _existingAssignment = assignment;
  }

  @override
  Future<Assignment?> getAssignmentByIds(
    String itemId,
    String containerId,
  ) async {
    return _existingAssignment;
  }

  @override
  Future<void> upsertAssignment(Assignment assignment) async {
    upsertedAssignments.add(assignment);
  }

  @override
  Future<void> deleteAssignment(String id) async {
    deletedIds.add(id);
  }

  @override
  Future<void> batchUpdateAssignments(List<Assignment> assignments) async {
    batchUpdatedAssignments.addAll(assignments);
  }

  // Unimplemented methods (not needed for these tests)
  @override
  Stream<List<Assignment>> watchAssignments() => throw UnimplementedError();

  @override
  Future<Assignment?> getAssignment(String id) => throw UnimplementedError();

  @override
  Future<List<Assignment>> getAssignmentsForContainer(String containerId) =>
      throw UnimplementedError();

  @override
  Future<List<Assignment>> getAssignmentsForItem(String itemId) =>
      throw UnimplementedError();

  @override
  Future<void> batchDeleteAssignments(List<String> assignmentIds) =>
      throw UnimplementedError();

  @override
  Stream<List<Assignment>> watchAssignmentsByContainer(String containerId) =>
      throw UnimplementedError();

  @override
  Stream<List<Assignment>> watchAssignmentsByItem(String itemId) =>
      throw UnimplementedError();

  @override
  Stream<Assignment?> watchAssignment(String assignmentId) =>
      throw UnimplementedError();
}

/// Mock WorkLogRepository for testing
class MockWorkLogRepositoryForService implements WorkLogRepository {
  final List<LogEntry> workLogs = [];

  @override
  Future<void> upsertWorkLog(LogEntry logEntry) async {
    workLogs.add(logEntry);
  }

  @override
  Future<void> createWorkLog(LogEntry logEntry) async {
    workLogs.add(logEntry);
  }

  // Unimplemented methods (not needed for these tests)
  @override
  Stream<List<LogEntry>> watchWorkLogs() => throw UnimplementedError();

  @override
  Future<LogEntry?> getWorkLog(String id) => throw UnimplementedError();

  @override
  Future<List<LogEntry>> getWorkLogsForItem(String itemId) =>
      throw UnimplementedError();

  @override
  Future<List<LogEntry>> getWorkLogsForContainer(String containerId) =>
      throw UnimplementedError();

  @override
  Future<List<LogEntry>> getWorkLogsSince(DateTime date) =>
      throw UnimplementedError();

  @override
  Future<List<LogEntry>> getWorkLogsBetween(
    DateTime startDate,
    DateTime endDate,
  ) => throw UnimplementedError();

  @override
  Future<void> batchCreateWorkLogs(List<LogEntry> logEntries) =>
      throw UnimplementedError();

  @override
  Future<void> deleteWorkLog(String id) => throw UnimplementedError();
}
