import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/models/sign.dart';
import 'package:rescuenet_warehouse/repositories/item_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_item_repository.dart';

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

/// Integration tests for Item CRUD operations.
/// Tests the full lifecycle of item management through the repository layer.
void main() {
  group('Item CRUD Integration Tests', () {
    late MockItemRepository mockRepo;

    setUp(() {
      // Create fresh mock repository for each test
      mockRepo = MockItemRepository();
      mockRepo.clearItems(); // Start with clean slate
    });

    tearDown(() {
      mockRepo.dispose();
    });

    group('Create Item', () {
      test('should create new item with basic required fields', () async {
        // Arrange
        final newItem = Item(
          id: 'new-item-001',
          name: 'Emergency Tent',
          rescueNetId: 2001.0,
          totalAmount: 25,
          weight: 8.5,
          description: 'Large emergency shelter tent',
          operationalStatus: OperationalStatus.deployable,
        );

        // Act
        await mockRepo.upsertItem(newItem);
        final retrievedItem = await mockRepo.getItem('new-item-001');

        // Assert
        expect(retrievedItem, isNotNull);
        expect(retrievedItem?.id, equals('new-item-001'));
        expect(retrievedItem?.name, equals('Emergency Tent'));
        expect(retrievedItem?.rescueNetId, equals(2001.0));
        expect(retrievedItem?.totalAmount, equals(25));
        expect(retrievedItem?.weight, equals(8.5));
        expect(
          retrievedItem?.description,
          equals('Large emergency shelter tent'),
        );
        expect(
          retrievedItem?.operationalStatus,
          equals(OperationalStatus.deployable),
        );
      });

      test('should create item with all optional fields populated', () async {
        // Arrange
        final expiryDate = DateTime(2025, 12, 31);
        final sign = Sign(
          id: 'sign-001',
          unNumber: 'UN1234',
          dangerType: 'Flammable',
          properShippingName: 'Test Chemical',
        );

        final fullItem = Item(
          id: 'full-item-001',
          name: 'Medical Supplies Kit',
          rescueNetId: 2002.0,
          totalAmount: 50,
          weight: 3.2,
          description: 'Complete medical supplies',
          expiringDates: [expiryDate],
          operationalStatus: OperationalStatus.deployable,
          manufacturer: 'MedCo International',
          brand: 'MedPro',
          type: 'Medical Kit',
          supplier: 'Global Supplies Ltd',
          website: 'https://medco.example.com',
          remarks: 'Handle with care',
          value: 15000,
          sku: 'MED-KIT-2024',
          notes: 'Requires temperature control',
          signs: [sign],
          isColdChain: true,
        );

        // Act
        await mockRepo.upsertItem(fullItem);
        final retrieved = await mockRepo.getItem('full-item-001');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved?.manufacturer, equals('MedCo International'));
        expect(retrieved?.brand, equals('MedPro'));
        expect(retrieved?.type, equals('Medical Kit'));
        expect(retrieved?.supplier, equals('Global Supplies Ltd'));
        expect(retrieved?.website, equals('https://medco.example.com'));
        expect(retrieved?.remarks, equals('Handle with care'));
        expect(retrieved?.value, equals(15000));
        expect(retrieved?.sku, equals('MED-KIT-2024'));
        expect(retrieved?.notes, equals('Requires temperature control'));
        expect(retrieved?.isColdChain, isTrue);
        expect(retrieved?.signs, hasLength(1));
        expect(retrieved?.expiringDates, hasLength(1));
      });
    });

    group('Update Item', () {
      test(
        'should update ALL modifiable item fields comprehensively',
        () async {
          // Arrange - Create initial item with minimal data
          final originalItem = createTestItem(
            id: 'update-test-001',
            name: 'Original Name',
            description: 'Original description',
            weight: 1.0,
          );
          await mockRepo.upsertItem(originalItem);

          // Prepare update with ALL modifiable fields changed
          final originalExpiryDate = DateTime(2024, 6, 30);
          final updatedExpiryDate = DateTime(2025, 12, 31);
          final newExpiryDate = DateTime(2026, 6, 30);

          final sign = Sign(
            id: 'sign-002',
            unNumber: 'UN5678',
            dangerType: 'Toxic',
            properShippingName: 'Hazardous Material',
            instructions: 'Keep away from heat',
            remarks: 'Danger sign',
            maxWeightPAX: 5.0,
            maxWeightCargo: 50.0,
          );

          final updatedItem = originalItem.copyWith(
            // Update all string fields
            name: 'Updated Item Name',
            description: 'Updated comprehensive description',
            manufacturer: 'Updated Manufacturer Corp',
            brand: 'Updated Brand',
            type: 'Updated Type Category',
            supplier: 'Updated Supplier LLC',
            website: 'https://updated-website.example.com',
            remarks: 'Updated remarks and notes',
            sku: 'UPDATED-SKU-2024',
            notes: 'Updated detailed notes about this item',

            // Update numeric fields
            weight: 5.5,
            value: 25000,

            // Update enum field
            operationalStatus: OperationalStatus.needsRepair,

            // Update boolean field
            isColdChain: true,

            // Update list fields
            expiringDates: [
              originalExpiryDate,
              updatedExpiryDate,
              newExpiryDate,
            ],
            signs: [sign],
          );

          // Act
          await mockRepo.upsertItem(updatedItem);
          final retrieved = await mockRepo.getItem('update-test-001');

          // Assert - Verify ALL fields were updated correctly
          expect(retrieved, isNotNull);

          // String fields
          expect(retrieved?.name, equals('Updated Item Name'));
          expect(
            retrieved?.description,
            equals('Updated comprehensive description'),
          );
          expect(retrieved?.manufacturer, equals('Updated Manufacturer Corp'));
          expect(retrieved?.brand, equals('Updated Brand'));
          expect(retrieved?.type, equals('Updated Type Category'));
          expect(retrieved?.supplier, equals('Updated Supplier LLC'));
          expect(
            retrieved?.website,
            equals('https://updated-website.example.com'),
          );
          expect(retrieved?.remarks, equals('Updated remarks and notes'));
          expect(retrieved?.sku, equals('UPDATED-SKU-2024'));
          expect(
            retrieved?.notes,
            equals('Updated detailed notes about this item'),
          );

          // Numeric fields
          expect(retrieved?.weight, equals(5.5));
          expect(retrieved?.value, equals(25000));

          // Enum field
          expect(
            retrieved?.operationalStatus,
            equals(OperationalStatus.needsRepair),
          );

          // Boolean field
          expect(retrieved?.isColdChain, isTrue);

          // List fields
          expect(retrieved?.expiringDates, hasLength(3));
          expect(retrieved?.expiringDates[0], equals(originalExpiryDate));
          expect(retrieved?.expiringDates[1], equals(updatedExpiryDate));
          expect(retrieved?.expiringDates[2], equals(newExpiryDate));

          expect(retrieved?.signs, hasLength(1));
          expect(retrieved?.signs[0].id, equals('sign-002'));
          expect(retrieved?.signs[0].unNumber, equals('UN5678'));
          expect(retrieved?.signs[0].dangerType, equals('Toxic'));
        },
      );

      test(
        'should update operational status from deployable to toBeReplaced',
        () async {
          // Arrange
          final item = createTestItem(
            id: 'status-test-001',
            status: OperationalStatus.deployable,
          );
          await mockRepo.upsertItem(item);

          // Act
          final updated = item.copyWith(
            operationalStatus: OperationalStatus.toBeReplaced,
          );
          await mockRepo.upsertItem(updated);
          final retrieved = await mockRepo.getItem('status-test-001');

          // Assert
          expect(
            retrieved?.operationalStatus,
            equals(OperationalStatus.toBeReplaced),
          );
        },
      );
    });

    group('Delete Item', () {
      test('should delete an existing item successfully', () async {
        // Arrange
        final item = createTestItem(id: 'delete-test-001');
        await mockRepo.upsertItem(item);

        // Verify item exists before deletion
        final itemBeforeDelete = await mockRepo.getItem('delete-test-001');
        expect(itemBeforeDelete, isNotNull);

        // Act
        await mockRepo.deleteItem('delete-test-001');

        // Assert
        final deletedItem = await mockRepo.getItem('delete-test-001');
        expect(deletedItem, isNull);
        expect(mockRepo.hasItem('delete-test-001'), isFalse);
      });

      test('should remove item from stream after deletion', () async {
        // Arrange
        final item = createTestItem(id: 'stream-delete-001');
        await mockRepo.upsertItem(item);

        // Act
        await mockRepo.deleteItem('stream-delete-001');

        // Assert - Verify stream doesn't contain deleted item
        final items = await mockRepo.watchItems().first;
        final deletedItemInStream = items.where(
          (i) => i.id == 'stream-delete-001',
        );
        expect(deletedItemInStream, isEmpty);
      });
    });

    group('Error Scenarios', () {
      test(
        'should throw ItemException when deleting non-existent item',
        () async {
          // Act & Assert
          expect(
            () => mockRepo.deleteItem('non-existent-item'),
            throwsA(isA<ItemException>()),
          );
        },
      );

      test('should handle multiple rapid updates correctly', () async {
        // Arrange
        final item = createTestItem(id: 'rapid-update-001', name: 'Initial');
        await mockRepo.upsertItem(item);

        // Act - Perform multiple rapid updates
        final futures = <Future>[];
        for (int i = 1; i <= 5; i++) {
          futures.add(mockRepo.upsertItem(item.copyWith(name: 'Update $i')));
        }
        await Future.wait(futures);

        // Assert - Final state should have the last update
        final retrieved = await mockRepo.getItem('rapid-update-001');
        expect(retrieved, isNotNull);
        expect(retrieved?.name, startsWith('Update'));
      });
    });

    group('Stream Operations', () {
      test('should emit updated item list when item is created', () async {
        // Arrange
        final streamFuture = mockRepo.watchItems().skip(1).first;

        // Act
        final newItem = createTestItem(id: 'stream-create-001');
        await mockRepo.upsertItem(newItem);

        // Assert
        final items = await streamFuture;
        expect(items.any((i) => i.id == 'stream-create-001'), isTrue);
      });

      test('should emit updated item list when item is updated', () async {
        // Arrange
        final item = createTestItem(id: 'stream-update-001', name: 'Original');
        await mockRepo.upsertItem(item);

        final streamFuture = mockRepo.watchItems().skip(1).first;

        // Act
        await mockRepo.upsertItem(item.copyWith(name: 'Updated'));

        // Assert
        final items = await streamFuture;
        final updatedItem = items.firstWhere(
          (i) => i.id == 'stream-update-001',
        );
        expect(updatedItem.name, equals('Updated'));
      });
    });
  });
}
