import 'dart:async';
import 'package:rescue_net_warehouse/models/log_entry.dart';
import 'package:rescue_net_warehouse/repositories/work_log_repository.dart';

/// Mock implementation of WorkLogRepository for testing
/// 
/// Provides predictable audit trail data and simulates real-time updates
/// without Firebase dependencies.
class MockWorkLogRepository implements WorkLogRepository {
  final Map<String, LogEntry> _workLogs = {};
  final StreamController<List<LogEntry>> _streamController = 
      StreamController<List<LogEntry>>.broadcast();

  MockWorkLogRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Sample work log entries for testing
    final now = DateTime.now();
    final sampleWorkLogs = [
      LogEntry(
        id: 'worklog_1',
        itemId: 'bandage_item',
        containerId: 'medical_container',
        count: 50,
        date: now.subtract(const Duration(hours: 2)),
        user: 'john.doe@example.com',
      ),
      LogEntry(
        id: 'worklog_2',
        itemId: 'water_bottle_item',
        containerId: 'food_container',
        count: 20,
        date: now.subtract(const Duration(hours: 1)),
        user: 'jane.smith@example.com',
      ),
      LogEntry(
        id: 'worklog_3',
        itemId: 'flashlight_item',
        containerId: 'tools_container',
        count: 5,
        date: now.subtract(const Duration(minutes: 30)),
        user: 'bob.wilson@example.com',
      ),
      LogEntry(
        id: 'worklog_4',
        itemId: 'bandage_item',
        containerId: 'medical_container',
        count: -10,
        date: now.subtract(const Duration(minutes: 15)),
        user: 'john.doe@example.com',
      ),
    ];

    for (final workLog in sampleWorkLogs) {
      _workLogs[workLog.id] = workLog;
    }
    
    _notifyListeners();
  }

  void _notifyListeners() {
    // Sort by date descending (most recent first)
    final sortedWorkLogs = _workLogs.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _streamController.add(sortedWorkLogs);
  }

  @override
  Stream<List<LogEntry>> watchWorkLogs() {
    return _streamController.stream;
  }

  @override
  Future<LogEntry?> getWorkLog(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _workLogs[id];
  }

  @override
  Future<List<LogEntry>> getWorkLogsForItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final workLogs = _workLogs.values
        .where((workLog) => workLog.itemId == itemId)
        .toList();
    workLogs.sort((a, b) => b.date.compareTo(a.date));
    return workLogs;
  }

  @override
  Future<List<LogEntry>> getWorkLogsForContainer(String containerId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final workLogs = _workLogs.values
        .where((workLog) => workLog.containerId == containerId)
        .toList();
    workLogs.sort((a, b) => b.date.compareTo(a.date));
    return workLogs;
  }

  @override
  Future<List<LogEntry>> getWorkLogsSince(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final workLogs = _workLogs.values
        .where((workLog) => workLog.date.isAfter(date) || workLog.date.isAtSameMomentAs(date))
        .toList();
    workLogs.sort((a, b) => b.date.compareTo(a.date));
    return workLogs;
  }

  @override
  Future<List<LogEntry>> getWorkLogsBetween(DateTime startDate, DateTime endDate) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final workLogs = _workLogs.values
        .where((workLog) => 
            (workLog.date.isAfter(startDate) || workLog.date.isAtSameMomentAs(startDate)) &&
            (workLog.date.isBefore(endDate) || workLog.date.isAtSameMomentAs(endDate)))
        .toList();
    workLogs.sort((a, b) => b.date.compareTo(a.date));
    return workLogs;
  }

  @override
  Future<void> createWorkLog(LogEntry logEntry) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _workLogs[logEntry.id] = logEntry;
    _notifyListeners();
  }

  @override
  Future<void> batchCreateWorkLogs(List<LogEntry> logEntries) async {
    await Future.delayed(const Duration(milliseconds: 20));
    
    for (final logEntry in logEntries) {
      _workLogs[logEntry.id] = logEntry;
    }
    
    _notifyListeners();
  }

  @override
  Future<void> deleteWorkLog(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _workLogs.remove(id);
    _notifyListeners();
  }

  /// Test helper methods
  
  /// Clear all work logs (useful for test setup)
  void clearAll() {
    _workLogs.clear();
    _notifyListeners();
  }

  /// Add work logs for testing specific scenarios
  void addTestWorkLogs(List<LogEntry> workLogs) {
    for (final workLog in workLogs) {
      _workLogs[workLog.id] = workLog;
    }
    _notifyListeners();
  }

  /// Get current work log count for testing
  int get workLogCount => _workLogs.length;

  /// Get work logs for a specific date (useful for testing date filtering)
  List<LogEntry> getWorkLogsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _workLogs.values
        .where((workLog) => 
            workLog.date.isAfter(startOfDay) && 
            workLog.date.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Dispose resources
  void dispose() {
    _streamController.close();
  }
}