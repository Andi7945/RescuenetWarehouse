import 'dart:async';
import '../../container_repository.dart';
import '../../../models/container_dao.dart';
import '../../../models/sequential_build.dart';

/// Mock implementation of ContainerRepository for testing.
/// Simulates container storage behavior without Firebase dependencies.
class MockContainerRepository implements ContainerRepository {
  final Map<String, ContainerDao> _containers = {};
  final StreamController<List<ContainerDao>> _containersController = StreamController<List<ContainerDao>>.broadcast();

  MockContainerRepository() {
    _initializeWithTestData();
  }

  /// Initialize with realistic test data
  void _initializeWithTestData() {
    final testContainers = [
      ContainerDao(
        id: 'test-container-1',
        number: 1,
        name: 'Medical Supplies Container',
        description: 'Container for medical equipment and supplies',
        typeId: 'medical-type-1',
        sequentialBuild: SequentialBuild.firstBuild,
        currentLocationId: 'warehouse-1',
        moduleDestinationId: 'mission-1',
        isReady: true,
        toDeploy: false,
      ),
      ContainerDao(
        id: 'test-container-2',
        number: 2,
        name: 'Emergency Supplies',
        description: 'General emergency supplies container',
        typeId: 'general-type-1',
        sequentialBuild: SequentialBuild.laterBuild,
        currentLocationId: 'warehouse-1',
        moduleDestinationId: 'mission-2',
        isReady: false,
        toDeploy: true,
      ),
      ContainerDao(
        id: 'test-container-3',
        number: 3,
        name: 'Water Purification Equipment',
        description: 'Container with water treatment equipment',
        typeId: 'water-type-1',
        sequentialBuild: SequentialBuild.preBuild,
        currentLocationId: 'warehouse-2',
        isReady: true,
        toDeploy: false,
      ),
    ];

    for (final container in testContainers) {
      _containers[container.id] = container;
    }
    _emitContainers();
  }

  @override
  Stream<List<ContainerDao>> watchContainers() {
    return _containersController.stream;
  }

  @override
  Future<ContainerDao?> getContainer(String id) async {
    await _simulateNetworkDelay();
    return _containers[id];
  }

  @override
  Future<void> upsertContainer(ContainerDao container) async {
    await _simulateNetworkDelay();
    _containers[container.id] = container;
    _emitContainers();
  }

  @override
  Future<void> deleteContainer(String id) async {
    await _simulateNetworkDelay();
    
    if (!_containers.containsKey(id)) {
      throw const ContainerException('Container not found', code: 'not-found');
    }
    
    _containers.remove(id);
    _emitContainers();
  }

  @override
  Future<List<ContainerDao>> getContainersByType(String containerTypeId) async {
    await _simulateNetworkDelay();
    
    return _containers.values.where((container) {
      return container.typeId == containerTypeId;
    }).toList();
  }

  @override
  Future<List<ContainerDao>> getContainersByLocation(String locationId) async {
    await _simulateNetworkDelay();
    
    return _containers.values.where((container) {
      return container.currentLocationId == locationId;
    }).toList();
  }

  @override
  Future<void> batchUpdateContainers(List<ContainerDao> containers) async {
    await _simulateNetworkDelay();
    
    for (final container in containers) {
      _containers[container.id] = container;
    }
    _emitContainers();
  }

  /// Emit current containers list to stream
  void _emitContainers() {
    _containersController.add(_containers.values.toList());
  }

  /// Simulate network delay for realistic testing
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Add test containers for specific test scenarios
  void addTestContainer(ContainerDao container) {
    _containers[container.id] = container;
    _emitContainers();
  }

  /// Clear all containers (useful for test cleanup)
  void clearContainers() {
    _containers.clear();
    _emitContainers();
  }

  /// Get current container count
  int get containerCount => _containers.length;

  /// Check if container exists by ID
  bool hasContainer(String id) => _containers.containsKey(id);

  /// Get containers by ready status
  List<ContainerDao> getContainersByReadyStatus(bool isReady) {
    return _containers.values.where((container) => container.isReady == isReady).toList();
  }

  /// Get containers by deploy status
  List<ContainerDao> getContainersByDeployStatus(bool toDeploy) {
    return _containers.values.where((container) => container.toDeploy == toDeploy).toList();
  }

  /// Dispose resources
  void dispose() {
    _containersController.close();
  }
}