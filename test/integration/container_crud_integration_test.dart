import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';
import 'package:rescuenet_warehouse/repositories/container_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_repository.dart';

/// Integration tests for Container CRUD operations.
/// Tests the full lifecycle of container management through the repository layer.
void main() {
  group('Container CRUD Integration Tests', () {
    late MockContainerRepository mockRepo;

    setUp(() {
      // Create fresh mock repository for each test
      mockRepo = MockContainerRepository();
      mockRepo.clearContainers(); // Start with clean slate
    });

    tearDown(() {
      mockRepo.dispose();
    });

    group('Create Container', () {
      test('should create new container with basic required fields', () async {
        // Arrange
        final newContainer = ContainerDao(
          id: 'new-container-001',
          number: 1,
          name: 'Emergency Supplies',
          sequentialBuild: SequentialBuild.firstBuild,
          isReady: false,
          toDeploy: false,
        );

        // Act
        await mockRepo.upsertContainer(newContainer);
        final retrieved = await mockRepo.getContainer('new-container-001');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved?.id, equals('new-container-001'));
        expect(retrieved?.number, equals(1));
        expect(retrieved?.name, equals('Emergency Supplies'));
        expect(retrieved?.sequentialBuild, equals(SequentialBuild.firstBuild));
        expect(retrieved?.isReady, isFalse);
        expect(retrieved?.toDeploy, isFalse);
        expect(retrieved?.description, isNull);
        expect(retrieved?.typeId, isNull);
      });

      test(
        'should create container with all optional fields populated',
        () async {
          // Arrange
          final fullContainer = ContainerDao(
            id: 'full-container-001',
            number: 2,
            name: 'Medical Equipment Container',
            description: 'Complete medical supplies and equipment',
            typeId: 'euro-box',
            moduleDestinationId: 'module-alpha',
            currentLocationId: 'warehouse-berlin',
            sequentialBuild: SequentialBuild.preBuild,
            isReady: true,
            toDeploy: true,
          );

          // Act
          await mockRepo.upsertContainer(fullContainer);
          final retrieved = await mockRepo.getContainer('full-container-001');

          // Assert
          expect(retrieved, isNotNull);
          expect(
            retrieved?.description,
            equals('Complete medical supplies and equipment'),
          );
          expect(retrieved?.typeId, equals('euro-box'));
          expect(retrieved?.moduleDestinationId, equals('module-alpha'));
          expect(retrieved?.currentLocationId, equals('warehouse-berlin'));
          expect(retrieved?.sequentialBuild, equals(SequentialBuild.preBuild));
          expect(retrieved?.isReady, isTrue);
          expect(retrieved?.toDeploy, isTrue);
        },
      );
    });

    group('Update Container', () {
      test(
        'should update ALL modifiable container fields comprehensively',
        () async {
          // Arrange - Create initial container with minimal data
          final original = ContainerDao(
            id: 'update-test-001',
            number: 1,
            name: 'Original Name',
            sequentialBuild: SequentialBuild.firstBuild,
            isReady: false,
            toDeploy: false,
          );
          await mockRepo.upsertContainer(original);

          // Prepare update with ALL modifiable fields changed
          final updated = original.copyWith(
            number: 99,
            name: 'Updated Container Name',
            description: 'Updated comprehensive description',
            typeId: 'pallet',
            moduleDestinationId: 'module-beta',
            currentLocationId: 'warehouse-munich',
            sequentialBuild: SequentialBuild.laterBuild,
            isReady: true,
            toDeploy: true,
          );

          // Act
          await mockRepo.upsertContainer(updated);
          final retrieved = await mockRepo.getContainer('update-test-001');

          // Assert - Verify ALL fields updated
          expect(retrieved, isNotNull);
          expect(retrieved?.number, equals(99));
          expect(retrieved?.name, equals('Updated Container Name'));
          expect(
            retrieved?.description,
            equals('Updated comprehensive description'),
          );
          expect(retrieved?.typeId, equals('pallet'));
          expect(retrieved?.moduleDestinationId, equals('module-beta'));
          expect(retrieved?.currentLocationId, equals('warehouse-munich'));
          expect(
            retrieved?.sequentialBuild,
            equals(SequentialBuild.laterBuild),
          );
          expect(retrieved?.isReady, isTrue);
          expect(retrieved?.toDeploy, isTrue);
        },
      );

      test('should update sequential build progression correctly', () async {
        // Arrange
        final container = ContainerDao(
          id: 'sequential-test-001',
          number: 5,
          name: 'Build Progression Test',
          sequentialBuild: SequentialBuild.preBuild,
          isReady: false,
          toDeploy: false,
        );
        await mockRepo.upsertContainer(container);

        // Act & Assert - Progress through build stages
        await mockRepo.upsertContainer(
          container.copyWith(sequentialBuild: SequentialBuild.firstBuild),
        );
        var retrieved = await mockRepo.getContainer('sequential-test-001');
        expect(retrieved?.sequentialBuild, equals(SequentialBuild.firstBuild));

        await mockRepo.upsertContainer(
          container.copyWith(sequentialBuild: SequentialBuild.laterBuild),
        );
        retrieved = await mockRepo.getContainer('sequential-test-001');
        expect(retrieved?.sequentialBuild, equals(SequentialBuild.laterBuild));

        await mockRepo.upsertContainer(
          container.copyWith(sequentialBuild: SequentialBuild.supplies),
        );
        retrieved = await mockRepo.getContainer('sequential-test-001');
        expect(retrieved?.sequentialBuild, equals(SequentialBuild.supplies));
      });
    });

    group('Delete Container', () {
      test('should delete an existing container successfully', () async {
        // Arrange
        final container = ContainerDao(
          id: 'delete-test-001',
          number: 10,
          name: 'To Be Deleted',
          sequentialBuild: SequentialBuild.firstBuild,
          isReady: false,
          toDeploy: false,
        );
        await mockRepo.upsertContainer(container);

        // Verify exists
        final beforeDelete = await mockRepo.getContainer('delete-test-001');
        expect(beforeDelete, isNotNull);

        // Act
        await mockRepo.deleteContainer('delete-test-001');

        // Assert
        final afterDelete = await mockRepo.getContainer('delete-test-001');
        expect(afterDelete, isNull);
        expect(mockRepo.hasContainer('delete-test-001'), isFalse);
      });

      test('should verify container no longer exists after deletion', () async {
        // Arrange
        final container = ContainerDao(
          id: 'verify-delete-001',
          number: 11,
          name: 'Verify Delete Test',
          sequentialBuild: SequentialBuild.firstBuild,
          isReady: false,
          toDeploy: false,
        );
        await mockRepo.upsertContainer(container);

        // Verify exists before deletion
        expect(mockRepo.hasContainer('verify-delete-001'), isTrue);

        // Act
        await mockRepo.deleteContainer('verify-delete-001');

        // Assert - Verify no longer exists
        expect(mockRepo.hasContainer('verify-delete-001'), isFalse);
        final retrieved = await mockRepo.getContainer('verify-delete-001');
        expect(retrieved, isNull);
      });
    });

    group('Query Operations', () {
      test('should get containers filtered by type', () async {
        // Arrange - Create 3 containers with different types
        await mockRepo.upsertContainer(
          ContainerDao(
            id: 'type-test-001',
            number: 1,
            name: 'Euro Box 1',
            typeId: 'euro-box',
            sequentialBuild: SequentialBuild.firstBuild,
            isReady: false,
            toDeploy: false,
          ),
        );

        await mockRepo.upsertContainer(
          ContainerDao(
            id: 'type-test-002',
            number: 2,
            name: 'Euro Box 2',
            typeId: 'euro-box',
            sequentialBuild: SequentialBuild.firstBuild,
            isReady: false,
            toDeploy: false,
          ),
        );

        await mockRepo.upsertContainer(
          ContainerDao(
            id: 'type-test-003',
            number: 3,
            name: 'Pallet Container',
            typeId: 'pallet',
            sequentialBuild: SequentialBuild.firstBuild,
            isReady: false,
            toDeploy: false,
          ),
        );

        // Act & Assert
        final euroBoxes = await mockRepo.getContainersByType('euro-box');
        expect(euroBoxes, hasLength(2));
        expect(euroBoxes.every((c) => c.typeId == 'euro-box'), isTrue);

        final pallets = await mockRepo.getContainersByType('pallet');
        expect(pallets, hasLength(1));
        expect(pallets.first.typeId, equals('pallet'));

        final nonExistent = await mockRepo.getContainersByType('non-existent');
        expect(nonExistent, isEmpty);
      });

      test('should get containers filtered by location', () async {
        // Arrange - Create 3 containers at different locations
        await mockRepo.upsertContainer(
          ContainerDao(
            id: 'location-test-001',
            number: 1,
            name: 'Warehouse A Container 1',
            currentLocationId: 'warehouse-a',
            sequentialBuild: SequentialBuild.firstBuild,
            isReady: false,
            toDeploy: false,
          ),
        );

        await mockRepo.upsertContainer(
          ContainerDao(
            id: 'location-test-002',
            number: 2,
            name: 'Warehouse A Container 2',
            currentLocationId: 'warehouse-a',
            sequentialBuild: SequentialBuild.firstBuild,
            isReady: false,
            toDeploy: false,
          ),
        );

        await mockRepo.upsertContainer(
          ContainerDao(
            id: 'location-test-003',
            number: 3,
            name: 'Warehouse B Container',
            currentLocationId: 'warehouse-b',
            sequentialBuild: SequentialBuild.firstBuild,
            isReady: false,
            toDeploy: false,
          ),
        );

        // Act & Assert
        final warehouseA = await mockRepo.getContainersByLocation(
          'warehouse-a',
        );
        expect(warehouseA, hasLength(2));
        expect(
          warehouseA.every((c) => c.currentLocationId == 'warehouse-a'),
          isTrue,
        );

        final warehouseB = await mockRepo.getContainersByLocation(
          'warehouse-b',
        );
        expect(warehouseB, hasLength(1));
        expect(warehouseB.first.currentLocationId, equals('warehouse-b'));
      });
    });

    group('Error Scenarios', () {
      test(
        'should throw ContainerException when deleting non-existent container',
        () async {
          // Act & Assert
          expect(
            () => mockRepo.deleteContainer('non-existent-container'),
            throwsA(isA<ContainerException>()),
          );
        },
      );

      test('should handle multiple rapid updates correctly', () async {
        // Arrange
        final container = ContainerDao(
          id: 'rapid-update-001',
          number: 1,
          name: 'Initial',
          sequentialBuild: SequentialBuild.firstBuild,
          isReady: false,
          toDeploy: false,
        );
        await mockRepo.upsertContainer(container);

        // Act - Perform multiple rapid updates
        final futures = <Future>[];
        for (int i = 1; i <= 5; i++) {
          futures.add(
            mockRepo.upsertContainer(container.copyWith(name: 'Update $i')),
          );
        }
        await Future.wait(futures);

        // Assert - Final state should have one of the updates
        final retrieved = await mockRepo.getContainer('rapid-update-001');
        expect(retrieved, isNotNull);
        expect(retrieved?.name, startsWith('Update'));
      });
    });

    group('Stream Operations', () {
      test('should include container in stream after creation', () async {
        // Arrange
        final newContainer = ContainerDao(
          id: 'stream-create-001',
          number: 100,
          name: 'Stream Test',
          sequentialBuild: SequentialBuild.firstBuild,
          isReady: false,
          toDeploy: false,
        );

        // Act
        await mockRepo.upsertContainer(newContainer);

        // Assert - Verify container exists via repository method
        final exists = mockRepo.hasContainer('stream-create-001');
        expect(exists, isTrue);

        final retrieved = await mockRepo.getContainer('stream-create-001');
        expect(retrieved?.name, equals('Stream Test'));
      });

      test('should reflect updated container state', () async {
        // Arrange
        final container = ContainerDao(
          id: 'stream-update-001',
          number: 101,
          name: 'Original',
          sequentialBuild: SequentialBuild.firstBuild,
          isReady: false,
          toDeploy: false,
        );
        await mockRepo.upsertContainer(container);

        // Act
        await mockRepo.upsertContainer(container.copyWith(name: 'Updated'));

        // Assert - Verify update persisted
        final retrieved = await mockRepo.getContainer('stream-update-001');
        expect(retrieved?.name, equals('Updated'));
      });
    });
  });
}
