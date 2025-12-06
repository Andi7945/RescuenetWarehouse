import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_item_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_assignment_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_auth_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_work_log_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_type_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_current_location_repository.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_module_destination_repository.dart';
import 'package:rescuenet_warehouse/repositories/item_repository.dart';
import 'package:rescuenet_warehouse/repositories/container_repository.dart';
import 'package:rescuenet_warehouse/repositories/assignment_repository.dart';

/// Test helpers for creating test data and provider containers
///
/// This file provides utilities for testing loading states and
/// creating test fixtures for the loading infrastructure tests.

/// Creates a test provider container with mock repositories
ProviderContainer createTestProviderContainer({
  List<Override> overrides = const [],
}) {
  final defaultOverrides = [
    // Override all repositories with mock implementations
    authRepositoryProvider.overrideWith((ref) => MockAuthRepository()),
    itemRepositoryProvider.overrideWith((ref) => MockItemRepository()),
    containerRepositoryProvider.overrideWith(
      (ref) => MockContainerRepository(),
    ),
    assignmentRepositoryProvider.overrideWith(
      (ref) => MockAssignmentRepository(),
    ),
    workLogRepositoryProvider.overrideWith((ref) => MockWorkLogRepository()),
    containerTypeRepositoryProvider.overrideWith(
      (ref) => MockContainerTypeRepository(),
    ),
    currentLocationRepositoryProvider.overrideWith(
      (ref) => MockCurrentLocationRepository(),
    ),
    moduleDestinationRepositoryProvider.overrideWith(
      (ref) => MockModuleDestinationRepository(),
    ),
  ];

  return ProviderContainer(overrides: [...defaultOverrides, ...overrides]);
}

/// Creates a test Item instance
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

/// Creates a test ContainerDao instance
ContainerDao createTestContainer({
  String id = 'test-container',
  String name = 'Test Container',
  String? description,
  String? typeId = 'euro-box',
  String? currentLocationId = 'warehouse-a',
  String? moduleDestinationId = 'module-1',
  int number = 1,
  SequentialBuild sequentialBuild = SequentialBuild.firstBuild,
  bool isReady = false,
  bool toDeploy = false,
}) {
  return ContainerDao(
    id: id,
    number: number,
    name: name,
    description: description,
    typeId: typeId,
    currentLocationId: currentLocationId,
    moduleDestinationId: moduleDestinationId,
    sequentialBuild: sequentialBuild,
    isReady: isReady,
    toDeploy: toDeploy,
  );
}

/// Creates a test Assignment instance
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

/// Creates multiple test items for testing lists
List<Item> createTestItems({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestItem(
      id: 'test-item-$index',
      name: 'Test Item $index',
      rescueNetId: 1001.0 + index,
    ),
  );
}

/// Creates multiple test containers for testing lists
List<ContainerDao> createTestContainers({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestContainer(
      id: 'test-container-$index',
      name: 'Test Container $index',
    ),
  );
}

/// Creates multiple test assignments for testing lists
List<Assignment> createTestAssignments({int count = 3}) {
  return List.generate(
    count,
    (index) => createTestAssignment(
      id: 'test-assignment-$index',
      itemId: 'test-item-$index',
      containerId: 'test-container-$index',
    ),
  );
}

/// Mock repository that throws errors for testing error scenarios
class ThrowingMockItemRepository implements ItemRepository {
  @override
  Future<void> upsertItem(Item item) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock repository error');
  }

  @override
  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock delete error');
  }

  @override
  Future<void> batchUpdateItems(List<Item> items) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock batch update error');
  }

  @override
  Stream<List<Item>> watchItems() {
    throw Exception('Mock watch error');
  }

  @override
  Future<Item?> getItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get error');
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock search error');
  }

  @override
  Future<List<Item>> getItemsByStatus(String operationalStatus) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get by status error');
  }
}

/// Mock repository that throws errors for container operations
class ThrowingMockContainerRepository implements ContainerRepository {
  @override
  Future<void> createContainer(ContainerDao container) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock container creation error');
  }

  @override
  Future<void> updateContainer(ContainerDao container) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock container update error');
  }

  @override
  Future<void> upsertContainer(ContainerDao container) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock container upsert error');
  }

  @override
  Future<void> deleteContainer(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock container delete error');
  }

  @override
  Future<void> batchUpdateContainers(List<ContainerDao> containers) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock container batch update error');
  }

  @override
  Future<List<ContainerDao>> getContainersByLocation(String locationId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get containers by location error');
  }

  @override
  Future<List<ContainerDao>> getContainersByType(String containerTypeId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get containers by type error');
  }

  @override
  Stream<List<ContainerDao>> watchContainers() {
    throw Exception('Mock container watch error');
  }

  @override
  Future<ContainerDao?> getContainer(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock container get error');
  }
}

/// Mock repository that throws errors for assignment operations
class ThrowingMockAssignmentRepository implements AssignmentRepository {
  @override
  Future<void> upsertAssignment(Assignment assignment) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock assignment upsert error');
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock assignment delete error');
  }

  @override
  Future<void> batchUpdateAssignments(List<Assignment> assignments) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock assignment batch update error');
  }

  @override
  Future<void> batchDeleteAssignments(List<String> assignmentIds) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock assignment batch delete error');
  }

  @override
  Future<Assignment?> getAssignment(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get assignment error');
  }

  @override
  Future<Assignment?> getAssignmentByIds(
    String itemId,
    String containerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get assignment by ids error');
  }

  @override
  Future<List<Assignment>> getAssignmentsForContainer(
    String containerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get assignments for container error');
  }

  @override
  Future<List<Assignment>> getAssignmentsForItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get assignments for item error');
  }

  @override
  Stream<List<Assignment>> watchAssignments() {
    throw Exception('Mock assignment watch error');
  }

  @override
  Future<List<Assignment>> getAssignmentsByItemId(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get assignments by item error');
  }

  @override
  Future<List<Assignment>> getAssignmentsByContainerId(
    String containerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Mock get assignments by container error');
  }

  @override
  Stream<List<Assignment>> watchAssignmentsByContainer(String containerId) {
    throw Exception('Mock watch assignments by container error');
  }

  @override
  Stream<List<Assignment>> watchAssignmentsByItem(String itemId) {
    throw Exception('Mock watch assignments by item error');
  }

  @override
  Stream<Assignment?> watchAssignment(String assignmentId) {
    throw Exception('Mock watch assignment error');
  }
}

/// Helper class to create AsyncValue states for testing
class AsyncValueTestHelper {
  /// Creates a loading AsyncValue
  static AsyncValue<T> loading<T>() => const AsyncValue.loading();

  /// Creates a data AsyncValue
  static AsyncValue<T> data<T>(T value) => AsyncValue.data(value);

  /// Creates an error AsyncValue
  static AsyncValue<T> error<T>(Object error, [StackTrace? stackTrace]) {
    return AsyncValue.error(error, stackTrace ?? StackTrace.current);
  }

  /// Creates a list of items wrapped in AsyncValue.data
  static AsyncValue<List<Item>> itemsData(List<Item> items) {
    return AsyncValue.data(items);
  }

  /// Creates a list of containers wrapped in AsyncValue.data
  static AsyncValue<List<ContainerDao>> containersData(
    List<ContainerDao> containers,
  ) {
    return AsyncValue.data(containers);
  }

  /// Creates a list of assignments wrapped in AsyncValue.data
  static AsyncValue<List<Assignment>> assignmentsData(
    List<Assignment> assignments,
  ) {
    return AsyncValue.data(assignments);
  }

  /// Creates a loading state for item lists
  static AsyncValue<List<Item>> itemsLoading() => const AsyncValue.loading();

  /// Creates an error state for item lists
  static AsyncValue<List<Item>> itemsError(Object error) {
    return AsyncValue.error(error, StackTrace.current);
  }

  /// Creates a loading state for container lists
  static AsyncValue<List<ContainerDao>> containersLoading() =>
      const AsyncValue.loading();

  /// Creates an error state for container lists
  static AsyncValue<List<ContainerDao>> containersError(Object error) {
    return AsyncValue.error(error, StackTrace.current);
  }
}
