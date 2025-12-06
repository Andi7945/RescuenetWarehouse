import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_assignment_repository.dart';

// Helper function to create test assignment
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

void main() {
  group('AssignmentRepository Rebuild Efficiency', () {
    late MockAssignmentRepository repo;

    setUp(() {
      repo = MockAssignmentRepository();
      // Clear initial sample data to start with clean state
      repo.clearAll();
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
