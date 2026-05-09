import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/repositories/assignment_repository.dart';
import 'package:rescuenet_warehouse/features/worklog/repository/work_log_repository.dart';
import 'package:rescuenet_warehouse/services/assignment/assignment_business_rules.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Service for managing assignment operations with side effects
///
/// Orchestrates:
/// - Assignment CRUD operations
/// - Work log creation (audit trail)
/// - Business rule validation
///
/// This service ensures assignments and work logs are created together,
/// maintaining data consistency and centralizing business logic.
class AssignmentService {
  final AssignmentRepository _assignmentRepository;
  final WorkLogRepository _workLogRepository;
  final String _currentUser;

  AssignmentService({
    required AssignmentRepository assignmentRepository,
    required WorkLogRepository workLogRepository,
    required String currentUser,
  }) : _assignmentRepository = assignmentRepository,
       _workLogRepository = workLogRepository,
       _currentUser = currentUser;

  /// Update or create assignment with automatic work log creation
  ///
  /// If newAmount is 0, the assignment will be deleted.
  /// If assignment doesn't exist and newAmount > 0, it will be created.
  ///
  /// Returns the updated/created assignment, or null if deleted.
  /// Throws exception if operation fails.
  Future<Assignment?> updateAssignment({
    required String itemId,
    required String containerId,
    required int newAmount,
  }) async {
    // 1. Get current assignment
    final currentAssignment = await _assignmentRepository.getAssignmentByIds(
      itemId,
      containerId,
    );

    // 2. Calculate delta for work log
    final delta = calculateAssignmentDelta(
      currentAssignment: currentAssignment,
      newAmount: newAmount,
    );

    // 3. If no change, return early
    if (delta == 0) {
      return currentAssignment;
    }

    // 4. Create or update assignment
    Assignment? resultAssignment;

    if (isEmptyAssignment(
      Assignment(
        id: currentAssignment?.id ?? '',
        itemId: itemId,
        containerId: containerId,
        count: newAmount,
      ),
    )) {
      // Delete if count is 0
      if (currentAssignment != null) {
        await _assignmentRepository.deleteAssignment(currentAssignment.id);
      }
      resultAssignment = null;
    } else {
      // Create or update
      final assignment =
          currentAssignment?.copyWith(count: newAmount) ??
          Assignment(
            id: '${itemId}__${containerId}',
            itemId: itemId,
            containerId: containerId,
            count: newAmount,
          );

      await _assignmentRepository.upsertAssignment(assignment);
      resultAssignment = assignment;
    }

    // 5. Create work log entry (only if assignment operation succeeded)
    final workLog = LogEntry(
      id: _uuid.v4(),
      itemId: itemId,
      containerId: containerId,
      count: delta,
      date: DateTime.now(),
      user: _currentUser,
    );

    await _workLogRepository.upsertWorkLog(workLog);

    return resultAssignment;
  }

  /// Create a new assignment with initial quantity
  ///
  /// Throws if assignment already exists.
  /// Automatically creates work log entry.
  Future<Assignment> createAssignment({
    required String itemId,
    required String containerId,
    required int initialCount,
  }) async {
    if (initialCount <= 0) {
      throw ArgumentError('Initial count must be greater than 0');
    }

    // Check if assignment already exists
    final existing = await _assignmentRepository.getAssignmentByIds(
      itemId,
      containerId,
    );

    if (existing != null) {
      throw StateError(
        'Assignment already exists for item $itemId in container $containerId',
      );
    }

    // Create new assignment
    final assignment = Assignment(
      id: '${itemId}__${containerId}',
      itemId: itemId,
      containerId: containerId,
      count: initialCount,
    );

    await _assignmentRepository.upsertAssignment(assignment);

    // Create work log
    final workLog = LogEntry(
      id: _uuid.v4(),
      itemId: itemId,
      containerId: containerId,
      count: initialCount,
      date: DateTime.now(),
      user: _currentUser,
    );

    await _workLogRepository.upsertWorkLog(workLog);

    return assignment;
  }

  /// Delete an assignment
  ///
  /// Creates work log entry with negative count to track removal.
  Future<void> deleteAssignment({
    required String assignmentId,
    required String itemId,
    required String containerId,
    required int currentCount,
  }) async {
    await _assignmentRepository.deleteAssignment(assignmentId);

    // Create work log entry for deletion
    final workLog = LogEntry(
      id: _uuid.v4(),
      itemId: itemId,
      containerId: containerId,
      count: -currentCount,
      date: DateTime.now(),
      user: _currentUser,
    );

    await _workLogRepository.upsertWorkLog(workLog);
  }

  /// Batch update multiple assignments
  ///
  /// All operations succeed or fail together (via repository batch).
  /// Creates work log entries for all changes.
  Future<void> batchUpdateAssignments({
    required List<Assignment> assignments,
    required List<int> deltas,
  }) async {
    if (assignments.length != deltas.length) {
      throw ArgumentError('Assignments and deltas must have same length');
    }

    // Update assignments in batch
    await _assignmentRepository.batchUpdateAssignments(assignments);

    // Create work log entries for all changes
    final workLogs = List.generate(assignments.length, (index) {
      return LogEntry(
        id: _uuid.v4(),
        itemId: assignments[index].itemId,
        containerId: assignments[index].containerId,
        count: deltas[index],
        date: DateTime.now(),
        user: _currentUser,
      );
    }).where((log) => log.count != 0).toList(); // Only log actual changes

    // Note: WorkLogRepository should support batch operations for efficiency
    // For now, insert individually
    for (final log in workLogs) {
      await _workLogRepository.upsertWorkLog(log);
    }
  }
}
