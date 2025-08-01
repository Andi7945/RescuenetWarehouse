import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/repositories/module_destination_repository.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';

/// Firebase implementation of ModuleDestinationRepository
/// 
/// Provides real-time synchronization with Firestore for module destination data.
class FirebaseModuleDestinationRepository implements ModuleDestinationRepository {
  @override
  Stream<List<ModuleDestination>> watchModuleDestinations() {
    return moduleDestinationsCollection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  @override
  Future<ModuleDestination?> getModuleDestination(String id) async {
    try {
      final doc = await moduleDestinationsCollection.doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get module destination: $e');
    }
  }

  @override
  Future<List<ModuleDestination>> getAllModuleDestinations() async {
    try {
      final querySnapshot = await moduleDestinationsCollection.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get all module destinations: $e');
    }
  }

  @override
  Future<void> upsertModuleDestination(ModuleDestination moduleDestination) async {
    try {
      await moduleDestinationsCollection.doc(moduleDestination.id).set(moduleDestination);
    } catch (e) {
      throw Exception('Failed to upsert module destination: $e');
    }
  }

  @override
  Future<void> deleteModuleDestination(String id) async {
    try {
      await moduleDestinationsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete module destination: $e');
    }
  }
}