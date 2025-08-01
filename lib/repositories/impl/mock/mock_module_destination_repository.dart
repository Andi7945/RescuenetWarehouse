import 'dart:async';
import 'package:rescue_net_warehouse/models/module_destination.dart';
import 'package:rescue_net_warehouse/repositories/module_destination_repository.dart';

/// Mock implementation of ModuleDestinationRepository for testing
/// 
/// Provides predictable destination data without Firebase dependencies.
class MockModuleDestinationRepository implements ModuleDestinationRepository {
  final Map<String, ModuleDestination> _moduleDestinations = {};
  final StreamController<List<ModuleDestination>> _streamController = 
      StreamController<List<ModuleDestination>>.broadcast();

  MockModuleDestinationRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Sample module destinations for testing
    final sampleDestinations = [
      const ModuleDestination(
        id: 'disaster_zone_1',
        name: 'Disaster Zone Alpha',
      ),
      const ModuleDestination(
        id: 'refugee_camp_a',
        name: 'Refugee Camp A',
      ),
      const ModuleDestination(
        id: 'medical_station_1',
        name: 'Field Medical Station',
      ),
      const ModuleDestination(
        id: 'base_camp_central',
        name: 'Base Camp Central',
      ),
      const ModuleDestination(
        id: 'forward_ops_bravo',
        name: 'Forward Operations Bravo',
      ),
    ];

    for (final destination in sampleDestinations) {
      _moduleDestinations[destination.id] = destination;
    }
    
    _notifyListeners();
  }

  void _notifyListeners() {
    _streamController.add(_moduleDestinations.values.toList());
  }

  @override
  Stream<List<ModuleDestination>> watchModuleDestinations() {
    return _streamController.stream;
  }

  @override
  Future<ModuleDestination?> getModuleDestination(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _moduleDestinations[id];
  }

  @override
  Future<List<ModuleDestination>> getAllModuleDestinations() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _moduleDestinations.values.toList();
  }

  @override
  Future<void> upsertModuleDestination(ModuleDestination moduleDestination) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _moduleDestinations[moduleDestination.id] = moduleDestination;
    _notifyListeners();
  }

  @override
  Future<void> deleteModuleDestination(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _moduleDestinations.remove(id);
    _notifyListeners();
  }

  /// Test helper methods
  
  /// Clear all module destinations (useful for test setup)
  void clearAll() {
    _moduleDestinations.clear();
    _notifyListeners();
  }

  /// Add module destinations for testing specific scenarios
  void addTestModuleDestinations(List<ModuleDestination> destinations) {
    for (final destination in destinations) {
      _moduleDestinations[destination.id] = destination;
    }
    _notifyListeners();
  }

  /// Get current destination count for testing
  int get moduleDestinationCount => _moduleDestinations.length;

  /// Dispose resources
  void dispose() {
    _streamController.close();
  }
}