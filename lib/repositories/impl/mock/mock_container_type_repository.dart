import 'dart:async';
import 'package:rescuenet_warehouse/models/container_type.dart';
import 'package:rescuenet_warehouse/repositories/container_type_repository.dart';

/// Mock implementation of ContainerTypeRepository for testing
/// 
/// Provides predictable container type data without Firebase dependencies.
class MockContainerTypeRepository implements ContainerTypeRepository {
  final Map<String, ContainerType> _containerTypes = {};
  final StreamController<List<ContainerType>> _streamController = 
      StreamController<List<ContainerType>>.broadcast();

  MockContainerTypeRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Sample container types for testing
    final sampleContainerTypes = [
      const ContainerType(
        id: 'medical_type',
        name: 'Medical Container',
        imagePath: 'assets/medical_container.png',
        emptyWeight: 5.5,
        measurements: '60x40x30 cm',
      ),
      const ContainerType(
        id: 'food_type',
        name: 'Food & Water Container',
        emptyWeight: 4.2,
        measurements: '80x60x45 cm',
      ),
      const ContainerType(
        id: 'tools_type',
        name: 'Tools & Equipment',
        imagePath: 'assets/tools_container.jpg',
        emptyWeight: 8.0,
        measurements: '100x60x50 cm',
      ),
      const ContainerType(
        id: 'emergency_type',
        name: 'Emergency Response Kit',
        emptyWeight: 3.8,
        measurements: '50x30x25 cm',
      ),
    ];

    for (final containerType in sampleContainerTypes) {
      _containerTypes[containerType.id] = containerType;
    }
    
    _notifyListeners();
  }

  void _notifyListeners() {
    _streamController.add(_containerTypes.values.toList());
  }

  @override
  Stream<List<ContainerType>> watchContainerTypes() {
    final controller = StreamController<List<ContainerType>>.broadcast();
    controller.add(_containerTypes.values.toList());
    final subscription = _streamController.stream.listen((items) => controller.add(items));
    controller.onCancel = () { subscription.cancel(); controller.close(); };
    return controller.stream;
  }

  @override
  Future<ContainerType?> getContainerType(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _containerTypes[id];
  }

  @override
  Future<List<ContainerType>> getAllContainerTypes() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _containerTypes.values.toList();
  }

  @override
  Future<void> upsertContainerType(ContainerType containerType) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _containerTypes[containerType.id] = containerType;
    _notifyListeners();
  }

  @override
  Future<void> deleteContainerType(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _containerTypes.remove(id);
    _notifyListeners();
  }

  /// Test helper methods
  
  /// Clear all container types (useful for test setup)
  void clearAll() {
    _containerTypes.clear();
    _notifyListeners();
  }

  /// Add container types for testing specific scenarios
  void addTestContainerTypes(List<ContainerType> containerTypes) {
    for (final containerType in containerTypes) {
      _containerTypes[containerType.id] = containerType;
    }
    _notifyListeners();
  }

  /// Get current container type count for testing
  int get containerTypeCount => _containerTypes.length;

  @override
  Future<void> createContainerType(ContainerType containerType) async {
    return upsertContainerType(containerType);
  }

  @override
  Future<void> updateContainerType(ContainerType containerType) async {
    return upsertContainerType(containerType);
  }

  /// Dispose resources
  void dispose() {
    _streamController.close();
  }
}