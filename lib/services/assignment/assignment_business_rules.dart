import 'package:rescuenet_warehouse/models/assignment.dart';

/// Pure business rule functions for assignments
/// No dependencies, no side effects - easy to test

/// Determine if an assignment should be deleted based on count
bool isEmptyAssignment(Assignment assignment) {
  return assignment.count == 0;
}

/// Calculate remaining quantity available for assignment
int calculateRemainingQuantity({
  required int totalAmount,
  required int alreadyAssigned,
}) {
  final remaining = totalAmount - alreadyAssigned;
  return remaining < 0 ? 0 : remaining;
}

/// Calculate assignment delta for work log tracking
/// Returns the change in quantity (positive = added, negative = removed)
int calculateAssignmentDelta({
  required Assignment? currentAssignment,
  required int newAmount,
}) {
  final currentCount = currentAssignment?.count ?? 0;
  return newAmount - currentCount;
}

/// Validate assignment quantity is valid
/// Returns error message if invalid, null if valid
String? validateAssignmentQuantity({
  required int requestedAmount,
  required int availableAmount,
  required int currentlyAssigned,
}) {
  if (requestedAmount < 0) {
    return 'Amount cannot be negative';
  }

  final availableAfterRemovingCurrent = availableAmount + currentlyAssigned;

  if (requestedAmount > availableAfterRemovingCurrent) {
    return 'Insufficient quantity. Available: $availableAfterRemovingCurrent, Requested: $requestedAmount';
  }

  return null; // Valid
}

/// Check if assignment already exists for item-container pair
bool assignmentExists({
  required List<Assignment> allAssignments,
  required String itemId,
  required String containerId,
}) {
  return allAssignments.any(
    (a) => a.itemId == itemId && a.containerId == containerId,
  );
}

/// Get total assigned quantity for an item
int getTotalAssignedForItem({
  required List<Assignment> allAssignments,
  required String itemId,
}) {
  return allAssignments
      .where((a) => a.itemId == itemId)
      .fold(0, (sum, assignment) => sum + assignment.count);
}

/// Get total assigned quantity in a container
int getTotalAssignedInContainer({
  required List<Assignment> allAssignments,
  required String containerId,
}) {
  return allAssignments
      .where((a) => a.containerId == containerId)
      .fold(0, (sum, assignment) => sum + assignment.count);
}
