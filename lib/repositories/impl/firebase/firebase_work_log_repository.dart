import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/work_log_repository.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';

/// Firebase implementation of WorkLogRepository
/// 
/// Provides real-time synchronization with Firestore for audit trail data.
/// Work logs are typically append-only for audit integrity.
class FirebaseWorkLogRepository implements WorkLogRepository {
  @override
  Stream<List<LogEntry>> watchWorkLogs() {
    return workLogCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  @override
  Future<LogEntry?> getWorkLog(String id) async {
    try {
      final doc = await workLogCollection.doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get work log: $e');
    }
  }

  @override
  Future<List<LogEntry>> getWorkLogsForItem(String itemId) async {
    try {
      final querySnapshot = await workLogCollection
          .where('itemId', isEqualTo: itemId)
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get work logs for item: $e');
    }
  }

  @override
  Future<List<LogEntry>> getWorkLogsForContainer(String containerId) async {
    try {
      final querySnapshot = await workLogCollection
          .where('containerId', isEqualTo: containerId)
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get work logs for container: $e');
    }
  }

  @override
  Future<List<LogEntry>> getWorkLogsSince(DateTime date) async {
    try {
      final querySnapshot = await workLogCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get work logs since date: $e');
    }
  }

  @override
  Future<List<LogEntry>> getWorkLogsBetween(DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await workLogCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get work logs between dates: $e');
    }
  }

  @override
  Future<void> createWorkLog(LogEntry logEntry) async {
    try {
      await workLogCollection.doc(logEntry.id).set(logEntry);
    } catch (e) {
      throw Exception('Failed to create work log: $e');
    }
  }

  @override
  Future<void> upsertWorkLog(LogEntry logEntry) async {
    return createWorkLog(logEntry);
  }

  @override
  Future<void> batchCreateWorkLogs(List<LogEntry> logEntries) async {
    if (logEntries.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (final logEntry in logEntries) {
        final docRef = workLogCollection.doc(logEntry.id);
        batch.set(docRef, logEntry);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create work logs: $e');
    }
  }

  @override
  Future<void> deleteWorkLog(String id) async {
    try {
      await workLogCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete work log: $e');
    }
  }
}