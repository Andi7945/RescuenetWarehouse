import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/assignments_by_container_notifier.dart';
import 'package:rescuenet_warehouse/state/assignments_by_item_notifier.dart';
import 'package:rescuenet_warehouse/state/assignment_by_id_notifier.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Assignment Provider Rebuild Efficiency', () {
    test('assignmentsByContainerProvider only rebuilds when container changes',
        () async {
      final providerContainer = createTestProviderContainer();

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
      final repo = providerContainer.read(assignmentRepositoryProvider);
      await repo.upsertAssignment(assignment1);
      await repo.upsertAssignment(assignment2);

      // Wait for data to be ready
      await Future.delayed(Duration(milliseconds: 50));

      // Track rebuilds for container-1
      int container1Rebuilds = 0;
      providerContainer.listen(
        assignmentsByContainerProvider('container-1'),
        (previous, next) {
          container1Rebuilds++;
        },
      );

      // Wait for initial provider load
      await Future.delayed(Duration(milliseconds: 50));
      container1Rebuilds = 0; // Reset after initial

      // Update assignment in container-2
      await repo.upsertAssignment(assignment2.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 50));

      // Container-1 provider should NOT rebuild
      expect(container1Rebuilds, equals(0));

      // Update assignment in container-1
      await repo.upsertAssignment(assignment1.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 50));

      // Container-1 provider SHOULD rebuild
      expect(container1Rebuilds, equals(1));

      providerContainer.dispose();
    });

    test('assignmentsByItemProvider only rebuilds when item changes',
        () async {
      final providerContainer = createTestProviderContainer();

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

      final repo = providerContainer.read(assignmentRepositoryProvider);
      await repo.upsertAssignment(assignment1);
      await repo.upsertAssignment(assignment2);

      await Future.delayed(Duration(milliseconds: 50));

      int item1Rebuilds = 0;
      providerContainer.listen(
        assignmentsByItemProvider('item-1'),
        (previous, next) {
          item1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 50));
      item1Rebuilds = 0;

      // Update assignment for item-2
      await repo.upsertAssignment(assignment2.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 50));

      expect(item1Rebuilds, equals(0));

      // Update assignment for item-1
      await repo.upsertAssignment(assignment1.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 50));

      expect(item1Rebuilds, equals(1));

      providerContainer.dispose();
    });

    test('assignmentByIdProvider only rebuilds for specific assignment',
        () async {
      final providerContainer = createTestProviderContainer();

      final assignment1 = createTestAssignment(id: 'assign-1');
      final assignment2 = createTestAssignment(id: 'assign-2');

      final repo = providerContainer.read(assignmentRepositoryProvider);
      await repo.upsertAssignment(assignment1);
      await repo.upsertAssignment(assignment2);

      await Future.delayed(Duration(milliseconds: 50));

      int assign1Rebuilds = 0;
      providerContainer.listen(
        assignmentByIdProvider('assign-1'),
        (previous, next) {
          assign1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 50));
      assign1Rebuilds = 0;

      // Update different assignment
      await repo.upsertAssignment(assignment2.copyWith(count: 15));
      await Future.delayed(Duration(milliseconds: 50));

      expect(assign1Rebuilds, equals(0));

      // Update tracked assignment
      await repo.upsertAssignment(assignment1.copyWith(count: 7));
      await Future.delayed(Duration(milliseconds: 50));

      expect(assign1Rebuilds, equals(1));

      providerContainer.dispose();
    });
  });
}
