import 'package:rescue_net_warehouse/models/container_type.dart';
import 'package:rescue_net_warehouse/repositories/container_type_repository.dart';
import 'package:rescue_net_warehouse/db/firebase.dart';

/// Firebase implementation of ContainerTypeRepository
/// 
/// Provides real-time synchronization with Firestore for container type data.
class FirebaseContainerTypeRepository implements ContainerTypeRepository {
  @override
  Stream<List<ContainerType>> watchContainerTypes() {
    return containerTypesCollection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  @override
  Future<ContainerType?> getContainerType(String id) async {
    try {
      final doc = await containerTypesCollection.doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get container type: $e');
    }
  }

  @override
  Future<List<ContainerType>> getAllContainerTypes() async {
    try {
      final querySnapshot = await containerTypesCollection.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get all container types: $e');
    }
  }

  @override
  Future<void> upsertContainerType(ContainerType containerType) async {
    try {
      await containerTypesCollection.doc(containerType.id).set(containerType);
    } catch (e) {
      throw Exception('Failed to upsert container type: $e');
    }
  }

  @override
  Future<void> deleteContainerType(String id) async {
    try {
      await containerTypesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete container type: $e');
    }
  }
}