import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_item_repository.dart';

// Helper function to create test item
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

void main() {
  group('ItemRepository Rebuild Efficiency', () {
    late MockItemRepository repo;

    setUp(() {
      repo = MockItemRepository();
      repo.clearItems();
    });

    tearDown(() {
      repo.dispose();
    });

    group('Baseline (Current Behavior)', () {
      test('watchItems() emits entire collection on any change', () async {
        final item1 = createTestItem(id: 'item-1', name: 'Item 1');
        final item2 = createTestItem(id: 'item-2', name: 'Item 2');

        await repo.upsertItem(item1);
        await repo.upsertItem(item2);

        int emissionCount = 0;
        final subscription = repo.watchItems().listen((_) {
          emissionCount++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        emissionCount = 0;

        // Update item 1
        await repo.upsertItem(item1.copyWith(name: 'Updated Item 1'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(emissionCount, greaterThan(0));

        subscription.cancel();
      });
    });

    group('Fine-Grained (Target Behavior)', () {
      test('watchItem() emits only when specific item changes', () async {
        final item1 = createTestItem(id: 'item-1', name: 'Item 1');
        final item2 = createTestItem(id: 'item-2', name: 'Item 2');

        await repo.upsertItem(item1);
        await repo.upsertItem(item2);

        int item1Emissions = 0;
        final subscription = repo.watchItem('item-1').listen((_) {
          item1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        item1Emissions = 0;

        // Update different item
        await repo.upsertItem(item2.copyWith(name: 'Updated Item 2'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(item1Emissions, equals(0));

        // Update tracked item
        await repo.upsertItem(item1.copyWith(name: 'Updated Item 1'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(item1Emissions, equals(1));

        subscription.cancel();
      });

      test('watchItemsByStatus() emits only when items with status change',
          () async {
        final deployable1 = createTestItem(
          id: 'item-1',
          name: 'Deployable 1',
          status: OperationalStatus.deployable,
        );
        final deployable2 = createTestItem(
          id: 'item-2',
          name: 'Deployable 2',
          status: OperationalStatus.deployable,
        );
        final needsRepair = createTestItem(
          id: 'item-3',
          name: 'Needs Repair',
          status: OperationalStatus.needsRepair,
        );

        await repo.upsertItem(deployable1);
        await repo.upsertItem(deployable2);
        await repo.upsertItem(needsRepair);

        int deployableEmissions = 0;
        final subscription = repo
            .watchItemsByStatus(OperationalStatus.deployable)
            .listen((_) {
          deployableEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        deployableEmissions = 0;

        // Update item with different status
        await repo.upsertItem(needsRepair.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(deployableEmissions, equals(0));

        // Update item with tracked status
        await repo.upsertItem(deployable1.copyWith(name: 'Updated Deployable'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(deployableEmissions, equals(1));

        subscription.cancel();
      });

      test('watchItemsByIds() emits only when subset changes', () async {
        final item1 = createTestItem(id: 'item-1');
        final item2 = createTestItem(id: 'item-2');
        final item3 = createTestItem(id: 'item-3');

        await repo.upsertItem(item1);
        await repo.upsertItem(item2);
        await repo.upsertItem(item3);

        int subsetEmissions = 0;
        final subscription = repo
            .watchItemsByIds(['item-1', 'item-2'])
            .listen((_) {
          subsetEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        subsetEmissions = 0;

        // Update item not in subset
        await repo.upsertItem(item3.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(subsetEmissions, equals(0));

        // Update item in subset
        await repo.upsertItem(item1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(subsetEmissions, equals(1));

        subscription.cancel();
      });
    });
  });
}
