import 'package:rescuenet_warehouse/models/assignment.dart';

/// Repository interface for managing item-container assignments.
/// 
/// This repository handles the many-to-many relationship between items and containers,
/// including batch operations and real-time synchronization capabilities.
abstract class AssignmentRepository {
  /// Stream of all assignments with real-time updates
  Stream<List<Assignment>> watchAssignments();

  /// Get a specific assignment by its ID
  Future<Assignment?> getAssignment(String id);

  /// Get all assignments for a specific container
  Future<List<Assignment>> getAssignmentsForContainer(String containerId);

  /// Get all assignments for a specific item
  Future<List<Assignment>> getAssignmentsForItem(String itemId);

  /// Get a specific assignment between an item and container
  Future<Assignment?> getAssignmentByIds(String itemId, String containerId);

  /// Create a new assignment
  /// If an assignment already exists between the item and container, updates the existing one
  Future<void> upsertAssignment(Assignment assignment);

  /// Delete an assignment by ID
  Future<void> deleteAssignment(String id);

  /// Update multiple assignments in a single transaction
  /// This is critical for maintaining data consistency during bulk operations
  Future<void> batchUpdateAssignments(List<Assignment> assignments);

  /// Delete multiple assignments in a single transaction
  Future<void> batchDeleteAssignments(List<String> assignmentIds);

  /// Upsert or delete assignment based on count (0 = delete, >0 = upsert)
  /// This matches the current business logic pattern
  Future<void> upsertOrDeleteAssignment(Assignment assignment);
}