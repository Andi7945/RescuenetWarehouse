import 'dart:async';
import 'package:rescue_net_warehouse/models/assignment.dart';
import 'package:rescue_net_warehouse/repositories/assignment_repository.dart';

/// Mock implementation of AssignmentRepository for testing
/// 
/// Provides predictable test data and simulates real-time updates
/// without Firebase dependencies.
class MockAssignmentRepository implements AssignmentRepository {
  final Map<String, Assignment> _assignments = {};
  final StreamController<List<Assignment>> _streamController = 
      StreamController<List<Assignment>>.broadcast();

  MockAssignmentRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Sample assignments for testing
    final sampleAssignments = [
      const Assignment(
        id: 'assignment_1',
        itemId: 'bandage_item',
        containerId: 'medical_container',
        count: 50,
      ),
      const Assignment(
        id: 'assignment_2',
        itemId: 'water_bottle_item',
        containerId: 'food_container',
        count: 20,
      ),
      const Assignment(
        id: 'assignment_3',
        itemId: 'flashlight_item',
        containerId: 'tools_container',
        count: 5,
      ),
      const Assignment(
        id: 'assignment_4',
        itemId: 'bandage_item',
        containerId: 'emergency_container',
        count: 25,
      ),
    ];

    for (final assignment in sampleAssignments) {
      _assignments[assignment.id] = assignment;
    }
    
    _notifyListeners();
  }

  void _notifyListeners() {
    _streamController.add(_assignments.values.toList());
  }

  @override
  Stream<List<Assignment>> watchAssignments() {
    return _streamController.stream;
  }

  @override
  Future<Assignment?> getAssignment(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 10));
    return _assignments[id];
  }

  @override
  Future<List<Assignment>> getAssignmentsForContainer(String containerId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _assignments.values
        .where((assignment) => assignment.containerId == containerId)
        .toList();
  }

  @override
  Future<List<Assignment>> getAssignmentsForItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _assignments.values
        .where((assignment) => assignment.itemId == itemId)
        .toList();
  }

  @override
  Future<Assignment?> getAssignmentByIds(String itemId, String containerId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    
    try {
      return _assignments.values.firstWhere(
        (assignment) => 
            assignment.itemId == itemId && 
            assignment.containerId == containerId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> upsertAssignment(Assignment assignment) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _assignments[assignment.id] = assignment;
    _notifyListeners();
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _assignments.remove(id);
    _notifyListeners();
  }

  @override
  Future<void> batchUpdateAssignments(List<Assignment> assignments) async {
    await Future.delayed(const Duration(milliseconds: 20));
    
    for (final assignment in assignments) {
      _assignments[assignment.id] = assignment;
    }
    
    _notifyListeners();
  }

  @override
  Future<void> batchDeleteAssignments(List<String> assignmentIds) async {
    await Future.delayed(const Duration(milliseconds: 20));
    
    for (final id in assignmentIds) {
      _assignments.remove(id);
    }
    
    _notifyListeners();
  }

  @override
  Future<void> upsertOrDeleteAssignment(Assignment assignment) async {
    await Future.delayed(const Duration(milliseconds: 10));
    
    if (assignment.count == 0) {
      await deleteAssignment(assignment.id);
    } else {
      await upsertAssignment(assignment);
    }
  }

  /// Test helper methods
  
  /// Clear all assignments (useful for test setup)
  void clearAll() {
    _assignments.clear();
    _notifyListeners();
  }

  /// Add assignments for testing specific scenarios
  void addTestAssignments(List<Assignment> assignments) {
    for (final assignment in assignments) {
      _assignments[assignment.id] = assignment;
    }
    _notifyListeners();
  }

  /// Get current assignment count for testing
  int get assignmentCount => _assignments.length;

  /// Dispose resources
  void dispose() {
    _streamController.close();
  }
}