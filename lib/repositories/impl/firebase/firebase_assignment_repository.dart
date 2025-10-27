import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/repositories/assignment_repository.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';

/// Firebase implementation of AssignmentRepository
///
/// Provides real-time synchronization with Firestore and supports
/// batch operations for maintaining data consistency.
class FirebaseAssignmentRepository implements AssignmentRepository {
  @override
  Stream<List<Assignment>> watchAssignments() {
    return assignmentCollection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  @override
  Future<Assignment?> getAssignment(String id) async {
    try {
      final doc = await assignmentCollection.doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get assignment: $e');
    }
  }

  @override
  Future<List<Assignment>> getAssignmentsForContainer(
    String containerId,
  ) async {
    try {
      final querySnapshot = await assignmentCollection
          .where('containerId', isEqualTo: containerId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get assignments for container: $e');
    }
  }

  @override
  Future<List<Assignment>> getAssignmentsForItem(String itemId) async {
    try {
      final querySnapshot = await assignmentCollection
          .where('itemId', isEqualTo: itemId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get assignments for item: $e');
    }
  }

  @override
  Future<Assignment?> getAssignmentByIds(
    String itemId,
    String containerId,
  ) async {
    try {
      final querySnapshot = await assignmentCollection
          .where('itemId', isEqualTo: itemId)
          .where('containerId', isEqualTo: containerId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      throw Exception('Failed to get assignment by IDs: $e');
    }
  }

  @override
  Future<void> upsertAssignment(Assignment assignment) async {
    try {
      await assignmentCollection.doc(assignment.id).set(assignment);
    } catch (e) {
      throw Exception('Failed to upsert assignment: $e');
    }
  }

  @override
  Future<void> deleteAssignment(String id) async {
    try {
      await assignmentCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  @override
  Future<void> batchUpdateAssignments(List<Assignment> assignments) async {
    if (assignments.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final assignment in assignments) {
        final docRef = assignmentCollection.doc(assignment.id);
        batch.set(docRef, assignment);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update assignments: $e');
    }
  }

  @override
  Future<void> batchDeleteAssignments(List<String> assignmentIds) async {
    if (assignmentIds.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final id in assignmentIds) {
        final docRef = assignmentCollection.doc(id);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch delete assignments: $e');
    }
  }
}
