import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/container_by_id_notifier.dart';
import 'package:rescuenet_warehouse/state/containers_by_location_notifier.dart';
import 'package:rescuenet_warehouse/state/containers_by_type_notifier.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_repository.dart';
import '../helpers/test_helpers.dart';

// Helper to create test provider container with shared repository
ProviderContainer createTestProviderContainerWithRepo(MockContainerRepository repo) {
  return ProviderContainer(
    overrides: [
      containerRepositoryProvider.overrideWith((ref) => repo),
    ],
  );
}

void main() {
  group('Container Provider Rebuild Efficiency', () {
    test('containerByIdProvider only rebuilds when specific container changes',
        () async {
      // Create shared repository instance
      final repo = MockContainerRepository();
      repo.clearContainers();
      final container = createTestProviderContainerWithRepo(repo);

      final container1 = createTestContainer(id: 'container-1');
      final container2 = createTestContainer(id: 'container-2');

      await repo.upsertContainer(container1);
      await repo.upsertContainer(container2);

      int container1Rebuilds = 0;
      container.listen(
        containerByIdProvider('container-1'),
        (previous, next) {
          container1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      container1Rebuilds = 0;

      // Update different container
      await repo.upsertContainer(container2.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(container1Rebuilds, equals(0));

      // Update tracked container
      await repo.upsertContainer(container1.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(container1Rebuilds, equals(1));

      repo.dispose();
      container.dispose();
    });

    test('containersByLocationProvider only rebuilds when location changes',
        () async {
      // Create shared repository instance
      final repo = MockContainerRepository();
      repo.clearContainers();
      final container = createTestProviderContainerWithRepo(repo);

      final warehouseA = createTestContainer(
        id: 'container-1',
        currentLocationId: 'warehouse-a',
      );
      final warehouseB = createTestContainer(
        id: 'container-2',
        currentLocationId: 'warehouse-b',
      );

      await repo.upsertContainer(warehouseA);
      await repo.upsertContainer(warehouseB);

      int warehouseARebuilds = 0;
      container.listen(
        containersByLocationProvider('warehouse-a'),
        (previous, next) {
          warehouseARebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      warehouseARebuilds = 0;

      // Update container in different location
      await repo.upsertContainer(warehouseB.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(warehouseARebuilds, equals(0));

      repo.dispose();
      container.dispose();
    });
  });
}
