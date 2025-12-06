import 'dart:async';
import '../../container_repository.dart';
import '../../../models/container_dao.dart';
import '../../../models/sequential_build.dart';

/// Mock implementation of ContainerRepository for testing.
/// Simulates container storage behavior without Firebase dependencies.
class MockContainerRepository implements ContainerRepository {
  final Map<String, ContainerDao> _containers = {};
  final StreamController<List<ContainerDao>> _containersController =
      StreamController<List<ContainerDao>>.broadcast();

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
    return _containers.values
        .where((container) => container.isReady == isReady)
        .toList();
  }

  /// Get containers by deploy status
  List<ContainerDao> getContainersByDeployStatus(bool toDeploy) {
    return _containers.values
        .where((container) => container.toDeploy == toDeploy)
        .toList();
  }

  @override
  Future<void> createContainer(ContainerDao container) async {
    return upsertContainer(container);
  }

  @override
  Future<void> updateContainer(ContainerDao container) async {
    return upsertContainer(container);
  }

  @override
  Stream<ContainerDao?> watchContainer(String containerId) {
    // Create a new controller for this specific container
    final controller = StreamController<ContainerDao?>.broadcast();

    // Track previous value to only emit when container actually changes
    ContainerDao? previousContainer = _containers[containerId];

    // Emit current container immediately
    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(previousContainer);
      }
    });

    // Forward future updates, but only when this specific container changes
    final subscription = _containersController.stream.listen((allContainers) {
      if (!controller.isClosed) {
        ContainerDao? currentContainer;
        try {
          currentContainer =
              allContainers.firstWhere((c) => c.id == containerId);
        } catch (e) {
          // Container not found
          currentContainer = null;
        }

        // Only emit if the container actually changed
        if (currentContainer != previousContainer) {
          controller.add(currentContainer);
          previousContainer = currentContainer;
        }
      }
    });

    // Handle cleanup
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<ContainerDao>> watchContainersByLocation(String locationId) {
    // Create a new controller for this location filter
    final controller = StreamController<List<ContainerDao>>.broadcast();

    // Emit current filtered containers immediately
    Future.microtask(() {
      if (!controller.isClosed) {
        final filtered = _containers.values
            .where((c) => c.currentLocationId == locationId)
            .toList();
        controller.add(filtered);
      }
    });

    // Forward future updates, but only when containers at this location change
    List<ContainerDao> previousFiltered = _containers.values
        .where((c) => c.currentLocationId == locationId)
        .toList();

    final subscription = _containersController.stream.listen((allContainers) {
      if (!controller.isClosed) {
        final currentFiltered =
            allContainers.where((c) => c.currentLocationId == locationId).toList();

        // Only emit if the filtered subset actually changed
        if (!_listEquals(previousFiltered, currentFiltered)) {
          controller.add(currentFiltered);
          previousFiltered = currentFiltered;
        }
      }
    });

    // Handle cleanup
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<ContainerDao>> watchContainersByType(String containerTypeId) {
    // Create a new controller for this type filter
    final controller = StreamController<List<ContainerDao>>.broadcast();

    // Emit current filtered containers immediately
    Future.microtask(() {
      if (!controller.isClosed) {
        final filtered = _containers.values
            .where((c) => c.typeId == containerTypeId)
            .toList();
        controller.add(filtered);
      }
    });

    // Forward future updates, but only when containers of this type change
    List<ContainerDao> previousFiltered =
        _containers.values.where((c) => c.typeId == containerTypeId).toList();

    final subscription = _containersController.stream.listen((allContainers) {
      if (!controller.isClosed) {
        final currentFiltered =
            allContainers.where((c) => c.typeId == containerTypeId).toList();

        // Only emit if the filtered subset actually changed
        if (!_listEquals(previousFiltered, currentFiltered)) {
          controller.add(currentFiltered);
          previousFiltered = currentFiltered;
        }
      }
    });

    // Handle cleanup
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<ContainerDao>> watchContainersByReadyStatus(bool isReady) {
    // Create a new controller for this ready status filter
    final controller = StreamController<List<ContainerDao>>.broadcast();

    // Emit current filtered containers immediately
    Future.microtask(() {
      if (!controller.isClosed) {
        final filtered =
            _containers.values.where((c) => c.isReady == isReady).toList();
        controller.add(filtered);
      }
    });

    // Forward future updates, but only when containers with this status change
    List<ContainerDao> previousFiltered =
        _containers.values.where((c) => c.isReady == isReady).toList();

    final subscription = _containersController.stream.listen((allContainers) {
      if (!controller.isClosed) {
        final currentFiltered =
            allContainers.where((c) => c.isReady == isReady).toList();

        // Only emit if the filtered subset actually changed
        if (!_listEquals(previousFiltered, currentFiltered)) {
          controller.add(currentFiltered);
          previousFiltered = currentFiltered;
        }
      }
    });

    // Handle cleanup
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<ContainerDao>> watchContainersByDeployStatus(bool toDeploy) {
    // Create a new controller for this deploy status filter
    final controller = StreamController<List<ContainerDao>>.broadcast();

    // Emit current filtered containers immediately
    Future.microtask(() {
      if (!controller.isClosed) {
        final filtered =
            _containers.values.where((c) => c.toDeploy == toDeploy).toList();
        controller.add(filtered);
      }
    });

    // Forward future updates, but only when containers with this status change
    List<ContainerDao> previousFiltered =
        _containers.values.where((c) => c.toDeploy == toDeploy).toList();

    final subscription = _containersController.stream.listen((allContainers) {
      if (!controller.isClosed) {
        final currentFiltered =
            allContainers.where((c) => c.toDeploy == toDeploy).toList();

        // Only emit if the filtered subset actually changed
        if (!_listEquals(previousFiltered, currentFiltered)) {
          controller.add(currentFiltered);
          previousFiltered = currentFiltered;
        }
      }
    });

    // Handle cleanup
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Helper to compare two lists of containers for equality
  bool _listEquals(List<ContainerDao> a, List<ContainerDao> b) {
    if (a.length != b.length) return false;

    // Sort by ID for consistent comparison
    final sortedA = List<ContainerDao>.from(a)
      ..sort((x, y) => x.id.compareTo(y.id));
    final sortedB = List<ContainerDao>.from(b)
      ..sort((x, y) => x.id.compareTo(y.id));

    for (var i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }

    return true;
  }

  /// Dispose resources
  void dispose() {
    _containersController.close();
  }
}
