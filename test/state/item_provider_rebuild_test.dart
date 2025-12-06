import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/item_by_id_notifier.dart';
import 'package:rescuenet_warehouse/state/items_by_status_notifier.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Helper to create test provider container with shared repository
ProviderContainer createTestProviderContainer(MockItemRepository repo) {
  return ProviderContainer(
    overrides: [
      itemRepositoryProvider.overrideWith((ref) => repo),
    ],
  );
}

void main() {
  group('Item Provider Rebuild Efficiency', () {
    test('itemByIdProvider only rebuilds when specific item changes',
        () async {
      // Create shared repository instance
      final repo = MockItemRepository();
      repo.clearItems();
      final container = createTestProviderContainer(repo);

      final item1 = createTestItem(id: 'item-1', name: 'Item 1');
      final item2 = createTestItem(id: 'item-2', name: 'Item 2');

      await repo.upsertItem(item1);
      await repo.upsertItem(item2);

      int item1Rebuilds = 0;
      container.listen(
        itemByIdProvider('item-1'),
        (previous, next) {
          item1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      item1Rebuilds = 0;

      // Update different item
      await repo.upsertItem(item2.copyWith(name: 'Updated Item 2'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(item1Rebuilds, equals(0));

      // Update tracked item
      await repo.upsertItem(item1.copyWith(name: 'Updated Item 1'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(item1Rebuilds, equals(1));

      repo.dispose();
      container.dispose();
    });

    test('itemsByStatusProvider only rebuilds when items with status change',
        () async {
      // Create shared repository instance
      final repo = MockItemRepository();
      repo.clearItems();
      final container = createTestProviderContainer(repo);

      final deployable = createTestItem(
        id: 'item-1',
        status: OperationalStatus.deployable,
      );
      final needsRepair = createTestItem(
        id: 'item-2',
        status: OperationalStatus.needsRepair,
      );

      await repo.upsertItem(deployable);
      await repo.upsertItem(needsRepair);

      int deployableRebuilds = 0;
      container.listen(
        itemsByStatusProvider(OperationalStatus.deployable),
        (previous, next) {
          deployableRebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      deployableRebuilds = 0;

      // Update item with different status
      await repo.upsertItem(needsRepair.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(deployableRebuilds, equals(0));

      // Update item with tracked status
      await repo.upsertItem(deployable.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(deployableRebuilds, equals(1));

      repo.dispose();
      container.dispose();
    });
  });
}
