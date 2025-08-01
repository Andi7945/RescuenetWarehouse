import 'package:rescuenet_warehouse/models/current_location.dart';

/// Repository interface for managing current locations.
/// 
/// Current locations represent physical locations where containers can be placed
/// or where operations are being conducted.
abstract class CurrentLocationRepository {
  /// Stream of all current locations with real-time updates
  Stream<List<CurrentLocation>> watchCurrentLocations();

  /// Get a specific current location by its ID
  Future<CurrentLocation?> getCurrentLocation(String id);

  /// Get all current locations as a list
  Future<List<CurrentLocation>> getAllCurrentLocations();

  /// Create or update a current location
  Future<void> upsertCurrentLocation(CurrentLocation currentLocation);

  /// Create a new current location
  /// Alias for upsertCurrentLocation for compatibility
  Future<void> createCurrentLocation(CurrentLocation currentLocation);

  /// Update an existing current location
  /// Alias for upsertCurrentLocation for compatibility
  Future<void> updateCurrentLocation(CurrentLocation currentLocation);

  /// Delete a current location by ID
  Future<void> deleteCurrentLocation(String id);
}