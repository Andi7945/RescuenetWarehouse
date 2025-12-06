import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/item_by_id_notifier.dart';
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
  group('Item Integration - Multi-Provider Rebuild', () {
    test('Updating Item A does not rebuild Item B watchers', () async {
      final repo = MockItemRepository();
      repo.clearItems();
      final container = createTestProviderContainer(repo);

      final itemA = createTestItem(id: 'item-a', name: 'Item A');
      final itemB = createTestItem(id: 'item-b', name: 'Item B');

      await repo.upsertItem(itemA);
      await repo.upsertItem(itemB);

      int itemBRebuilds = 0;
      container.listen(
        itemByIdProvider('item-b'),
        (previous, next) {
          itemBRebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      itemBRebuilds = 0;

      // Update Item A
      await repo.upsertItem(itemA.copyWith(name: 'Updated Item A'));
      await Future.delayed(Duration(milliseconds: 100));

      // Item B provider should NOT rebuild
      expect(itemBRebuilds, equals(0));

      repo.dispose();
      container.dispose();
    });

    test('Multiple item watchers only rebuild their specific items', () async {
      final repo = MockItemRepository();
      repo.clearItems();
      final container = createTestProviderContainer(repo);

      final item1 = createTestItem(id: 'item-1', name: 'Item 1');
      final item2 = createTestItem(id: 'item-2', name: 'Item 2');
      final item3 = createTestItem(id: 'item-3', name: 'Item 3');

      await repo.upsertItem(item1);
      await repo.upsertItem(item2);
      await repo.upsertItem(item3);

      int item1Rebuilds = 0;
      int item2Rebuilds = 0;
      int item3Rebuilds = 0;

      container.listen(itemByIdProvider('item-1'), (prev, next) => item1Rebuilds++);
      container.listen(itemByIdProvider('item-2'), (prev, next) => item2Rebuilds++);
      container.listen(itemByIdProvider('item-3'), (prev, next) => item3Rebuilds++);

      await Future.delayed(Duration(milliseconds: 100));
      item1Rebuilds = 0;
      item2Rebuilds = 0;
      item3Rebuilds = 0;

      // Update only item 2
      await repo.upsertItem(item2.copyWith(name: 'Updated Item 2'));
      await Future.delayed(Duration(milliseconds: 100));

      // Only item 2 should rebuild
      expect(item1Rebuilds, equals(0));
      expect(item2Rebuilds, equals(1));
      expect(item3Rebuilds, equals(0));

      repo.dispose();
      container.dispose();
    });
  });
}
