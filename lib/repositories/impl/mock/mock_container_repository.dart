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

  /// Initialize with realistic test data matching Playwright test expectations
  void _initializeWithTestData() {
    final testContainers = [
      ContainerDao(
        id: 'container-1',
        number: 1,
        name: 'Genset 1',
        description: 'Generator container',
        typeId: 'type-1',
        sequentialBuild: SequentialBuild.firstBuild,
        currentLocationId: 'loc-1',
        moduleDestinationId: 'dest-1',
        isReady: false,
        toDeploy: false,
      ),
      ContainerDao(
        id: 'container-2',
        number: 2,
        name: 'Medical Supplies',
        description: 'Medical equipment container',
        typeId: 'type-2',
        sequentialBuild: SequentialBuild.preBuild,
        currentLocationId: 'loc-2',
        moduleDestinationId: 'dest-2',
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
    // Create a new controller that emits current data immediately
    final controller = StreamController<List<ContainerDao>>.broadcast();
    
    // Emit current data immediately
    controller.add(_containers.values.toList());
    
    // Forward future updates
    final subscription = _containersController.stream.listen(
      (containers) => controller.add(containers),
    );
    
    // Handle cleanup
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    
    return controller.stream;
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

  @override
  Future<void> createContainer(ContainerDao container) async {
    return upsertContainer(container);
  }

  @override
  Future<void> updateContainer(ContainerDao container) async {
    return upsertContainer(container);
  }

  /// Dispose resources
  void dispose() {
    _containersController.close();
  }
}