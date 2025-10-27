import 'dart:async';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/repositories/current_location_repository.dart';

/// Mock implementation of CurrentLocationRepository for testing
///
/// Provides predictable location data without Firebase dependencies.
class MockCurrentLocationRepository implements CurrentLocationRepository {
  final Map<String, CurrentLocation> _currentLocations = {};
  final StreamController<List<CurrentLocation>> _streamController =
      StreamController<List<CurrentLocation>>.broadcast();

  MockCurrentLocationRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Sample current locations for testing
    final sampleLocations = [
      const CurrentLocation(id: 'warehouse_main', name: 'Main Warehouse'),
      const CurrentLocation(id: 'field_office_1', name: 'Field Office Alpha'),
      const CurrentLocation(id: 'deployment_zone_a', name: 'Deployment Zone A'),
      const CurrentLocation(id: 'transport_hub', name: 'Transport Hub'),
      const CurrentLocation(id: 'staging_area', name: 'Staging Area'),
    ];

    for (final location in sampleLocations) {
      _currentLocations[location.id] = location;
    }

    _notifyListeners();
  }

  void _notifyListeners() {
    _streamController.add(_currentLocations.values.toList());
  }

  @override
  Stream<List<CurrentLocation>> watchCurrentLocations() {
    final controller = StreamController<List<CurrentLocation>>.broadcast();
    controller.add(_currentLocations.values.toList());
    final subscription = _streamController.stream.listen(
      (items) => controller.add(items),
    );
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    return controller.stream;
  }

  @override
  Future<CurrentLocation?> getCurrentLocation(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _currentLocations[id];
  }

  @override
  Future<List<CurrentLocation>> getAllCurrentLocations() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _currentLocations.values.toList();
  }

  @override
  Future<void> upsertCurrentLocation(CurrentLocation currentLocation) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _currentLocations[currentLocation.id] = currentLocation;
    _notifyListeners();
  }

  @override
  Future<void> deleteCurrentLocation(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _currentLocations.remove(id);
    _notifyListeners();
  }

  /// Test helper methods

  /// Clear all current locations (useful for test setup)
  void clearAll() {
    _currentLocations.clear();
    _notifyListeners();
  }

  /// Add current locations for testing specific scenarios
  void addTestCurrentLocations(List<CurrentLocation> locations) {
    for (final location in locations) {
      _currentLocations[location.id] = location;
    }
    _notifyListeners();
  }

  @override
  Future<void> createCurrentLocation(CurrentLocation currentLocation) async {
    return upsertCurrentLocation(currentLocation);
  }

  @override
  Future<void> updateCurrentLocation(CurrentLocation currentLocation) async {
    return upsertCurrentLocation(currentLocation);
  }

  /// Get current location count for testing
  int get currentLocationCount => _currentLocations.length;

  /// Dispose resources
  void dispose() {
    _streamController.close();
  }
}
