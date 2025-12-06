import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_repository.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ContainerRepository Rebuild Efficiency', () {
    late MockContainerRepository repo;

    setUp(() {
      repo = MockContainerRepository();
      repo.clearContainers();
    });

    tearDown(() {
      repo.dispose();
    });

    group('Baseline (Current Behavior)', () {
      test('watchContainers() emits entire collection on any change', () async {
        final container1 = createTestContainer(id: 'container-1', name: 'Container 1');
        final container2 = createTestContainer(id: 'container-2', name: 'Container 2');

        await repo.upsertContainer(container1);
        await repo.upsertContainer(container2);

        int emissionCount = 0;
        final subscription = repo.watchContainers().listen((_) {
          emissionCount++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        emissionCount = 0;

        await repo.upsertContainer(container1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(emissionCount, greaterThan(0));

        subscription.cancel();
      });
    });

    group('Fine-Grained (Target Behavior)', () {
      test('watchContainer() emits only when specific container changes', () async {
        final container1 = createTestContainer(id: 'container-1');
        final container2 = createTestContainer(id: 'container-2');

        await repo.upsertContainer(container1);
        await repo.upsertContainer(container2);

        int container1Emissions = 0;
        final subscription = repo.watchContainer('container-1').listen((_) {
          container1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        container1Emissions = 0;

        // Update different container
        await repo.upsertContainer(container2.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(container1Emissions, equals(0));

        // Update tracked container
        await repo.upsertContainer(container1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(container1Emissions, equals(1));

        subscription.cancel();
      });

      test('watchContainersByLocation() emits only when location changes', () async {
        final warehouseA1 = createTestContainer(
          id: 'container-1',
          currentLocationId: 'warehouse-a',
        );
        final warehouseA2 = createTestContainer(
          id: 'container-2',
          currentLocationId: 'warehouse-a',
        );
        final warehouseB = createTestContainer(
          id: 'container-3',
          currentLocationId: 'warehouse-b',
        );

        await repo.upsertContainer(warehouseA1);
        await repo.upsertContainer(warehouseA2);
        await repo.upsertContainer(warehouseB);

        int warehouseAEmissions = 0;
        final subscription = repo
            .watchContainersByLocation('warehouse-a')
            .listen((_) {
          warehouseAEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        warehouseAEmissions = 0;

        // Update container in different location
        await repo.upsertContainer(warehouseB.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(warehouseAEmissions, equals(0));

        // Update container in tracked location
        await repo.upsertContainer(warehouseA1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(warehouseAEmissions, equals(1));

        subscription.cancel();
      });

      test('watchContainersByType() emits only when type changes', () async {
        final euroBox1 = createTestContainer(
          id: 'container-1',
          typeId: 'euro-box',
        );
        final euroBox2 = createTestContainer(
          id: 'container-2',
          typeId: 'euro-box',
        );
        final palette = createTestContainer(
          id: 'container-3',
          typeId: 'palette',
        );

        await repo.upsertContainer(euroBox1);
        await repo.upsertContainer(euroBox2);
        await repo.upsertContainer(palette);

        int euroBoxEmissions = 0;
        final subscription = repo
            .watchContainersByType('euro-box')
            .listen((_) {
          euroBoxEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        euroBoxEmissions = 0;

        // Update container with different type
        await repo.upsertContainer(palette.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(euroBoxEmissions, equals(0));

        // Update container with tracked type
        await repo.upsertContainer(euroBox1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(euroBoxEmissions, equals(1));

        subscription.cancel();
      });

      test('watchContainersByReadyStatus() emits only when ready status changes', () async {
        final ready = createTestContainer(id: 'container-1', isReady: true);
        final notReady = createTestContainer(id: 'container-2', isReady: false);

        await repo.upsertContainer(ready);
        await repo.upsertContainer(notReady);

        int readyEmissions = 0;
        final subscription = repo
            .watchContainersByReadyStatus(true)
            .listen((_) {
          readyEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        readyEmissions = 0;

        // Update not-ready container
        await repo.upsertContainer(notReady.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(readyEmissions, equals(0));

        // Update ready container
        await repo.upsertContainer(ready.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(readyEmissions, equals(1));

        subscription.cancel();
      });
    });
  });
}
