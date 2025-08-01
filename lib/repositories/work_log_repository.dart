import 'package:rescue_net_warehouse/models/log_entry.dart';

/// Repository interface for managing work log entries (audit trail).
/// 
/// This repository handles the audit trail of all item-container assignment changes,
/// providing real-time synchronization and historical data access.
abstract class WorkLogRepository {
  /// Stream of all work log entries with real-time updates
  Stream<List<LogEntry>> watchWorkLogs();

  /// Get a specific work log entry by its ID
  Future<LogEntry?> getWorkLog(String id);

  /// Get all work log entries for a specific item
  Future<List<LogEntry>> getWorkLogsForItem(String itemId);

  /// Get all work log entries for a specific container
  Future<List<LogEntry>> getWorkLogsForContainer(String containerId);

  /// Get work log entries since a specific date
  Future<List<LogEntry>> getWorkLogsSince(DateTime date);

  /// Get work log entries within a date range
  Future<List<LogEntry>> getWorkLogsBetween(DateTime startDate, DateTime endDate);

  /// Create a new work log entry
  Future<void> createWorkLog(LogEntry logEntry);

  /// Create multiple work log entries in a batch
  /// This is important for maintaining consistency when logging bulk operations
  Future<void> batchCreateWorkLogs(List<LogEntry> logEntries);

  /// Delete a work log entry (rarely used - for error correction)
  Future<void> deleteWorkLog(String id);
}