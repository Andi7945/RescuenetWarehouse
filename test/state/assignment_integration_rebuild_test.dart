import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/assignments_by_container_notifier.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
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
