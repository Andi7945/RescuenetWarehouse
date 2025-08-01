import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/repositories/current_location_repository.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';

/// Firebase implementation of CurrentLocationRepository
/// 
/// Provides real-time synchronization with Firestore for current location data.
class FirebaseCurrentLocationRepository implements CurrentLocationRepository {
  @override
  Stream<List<CurrentLocation>> watchCurrentLocations() {
    return currentLocationsCollection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  @override
  Future<CurrentLocation?> getCurrentLocation(String id) async {
    try {
      final doc = await currentLocationsCollection.doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  @override
  Future<List<CurrentLocation>> getAllCurrentLocations() async {
    try {
      final querySnapshot = await currentLocationsCollection.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get all current locations: $e');
    }
  }

  @override
  Future<void> upsertCurrentLocation(CurrentLocation currentLocation) async {
    try {
      await currentLocationsCollection.doc(currentLocation.id).set(currentLocation);
    } catch (e) {
      throw Exception('Failed to upsert current location: $e');
    }
  }

  @override
  Future<void> deleteCurrentLocation(String id) async {
    try {
      await currentLocationsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete current location: $e');
    }
  }
}