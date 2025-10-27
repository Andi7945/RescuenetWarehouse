import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/services/assignment/assignment_business_rules.dart';

void main() {
  group('isEmptyAssignment', () {
    test('returns true when count is 0', () {
      final assignment = Assignment(
        id: '1',
        itemId: 'item1',
        containerId: 'container1',
        count: 0,
      );

      expect(isEmptyAssignment(assignment), isTrue);
    });

    test('returns false when count is positive', () {
      final assignment = Assignment(
        id: '1',
        itemId: 'item1',
        containerId: 'container1',
        count: 5,
      );

      expect(isEmptyAssignment(assignment), isFalse);
    });

    test('returns false when count is 1', () {
      final assignment = Assignment(
        id: '1',
        itemId: 'item1',
        containerId: 'container1',
        count: 1,
      );

      expect(isEmptyAssignment(assignment), isFalse);
    });
  });

  group('calculateRemainingQuantity', () {
    test('returns correct remaining when totalAmount > alreadyAssigned', () {
      expect(
        calculateRemainingQuantity(totalAmount: 100, alreadyAssigned: 30),
        equals(70),
      );
    });

    test('returns 0 when totalAmount equals alreadyAssigned', () {
      expect(
        calculateRemainingQuantity(totalAmount: 50, alreadyAssigned: 50),
        equals(0),
      );
    });

    test(
      'returns 0 when totalAmount < alreadyAssigned (negative protection)',
      () {
        expect(
          calculateRemainingQuantity(totalAmount: 30, alreadyAssigned: 50),
          equals(0),
        );
      },
    );

    test('returns totalAmount when alreadyAssigned is 0', () {
      expect(
        calculateRemainingQuantity(totalAmount: 100, alreadyAssigned: 0),
        equals(100),
      );
    });

    test('returns 0 when both are 0', () {
      expect(
        calculateRemainingQuantity(totalAmount: 0, alreadyAssigned: 0),
        equals(0),
      );
    });
  });

  group('calculateAssignmentDelta', () {
    test('returns positive delta when increasing from existing assignment', () {
      final currentAssignment = Assignment(
        id: '1',
        itemId: 'item1',
        containerId: 'container1',
        count: 5,
      );

      expect(
        calculateAssignmentDelta(
          currentAssignment: currentAssignment,
          newAmount: 10,
        ),
        equals(5),
      );
    });

    test('returns negative delta when decreasing existing assignment', () {
      final currentAssignment = Assignment(
        id: '1',
        itemId: 'item1',
        containerId: 'container1',
        count: 10,
      );

      expect(
        calculateAssignmentDelta(
          currentAssignment: currentAssignment,
          newAmount: 3,
        ),
        equals(-7),
      );
    });

    test('returns 0 when amount unchanged', () {
      final currentAssignment = Assignment(
        id: '1',
        itemId: 'item1',
        containerId: 'container1',
        count: 5,
      );

      expect(
        calculateAssignmentDelta(
          currentAssignment: currentAssignment,
          newAmount: 5,
        ),
        equals(0),
      );
    });

    test(
      'returns newAmount when currentAssignment is null (new assignment)',
      () {
        expect(
          calculateAssignmentDelta(currentAssignment: null, newAmount: 8),
          equals(8),
        );
      },
    );

    test('returns negative when reducing to 0', () {
      final currentAssignment = Assignment(
        id: '1',
        itemId: 'item1',
        containerId: 'container1',
        count: 5,
      );

      expect(
        calculateAssignmentDelta(
          currentAssignment: currentAssignment,
          newAmount: 0,
        ),
        equals(-5),
      );
    });
  });

  group('validateAssignmentQuantity', () {
    test('returns null when requested amount is valid', () {
      expect(
        validateAssignmentQuantity(
          requestedAmount: 30,
          availableAmount: 50,
          currentlyAssigned: 0,
        ),
        isNull,
      );
    });

    test('returns error when requested amount is negative', () {
      final error = validateAssignmentQuantity(
        requestedAmount: -5,
        availableAmount: 50,
        currentlyAssigned: 0,
      );

      expect(error, isNotNull);
      expect(error, contains('cannot be negative'));
    });

    test(
      'returns error when requested exceeds available (no current assignment)',
      () {
        final error = validateAssignmentQuantity(
          requestedAmount: 60,
          availableAmount: 50,
          currentlyAssigned: 0,
        );

        expect(error, isNotNull);
        expect(error, contains('Insufficient quantity'));
        expect(error, contains('Available: 50'));
        expect(error, contains('Requested: 60'));
      },
    );

    test('returns null when requested equals available', () {
      expect(
        validateAssignmentQuantity(
          requestedAmount: 50,
          availableAmount: 50,
          currentlyAssigned: 0,
        ),
        isNull,
      );
    });

    test('allows increasing when current assignment is accounted for', () {
      // Available: 50, Currently assigned here: 10
      // If we remove the 10, we have 60 available
      // Requesting 55 should be valid
      expect(
        validateAssignmentQuantity(
          requestedAmount: 55,
          availableAmount: 50,
          currentlyAssigned: 10,
        ),
        isNull,
      );
    });

    test(
      'returns error when increasing beyond available even with current assignment',
      () {
        // Available: 50, Currently assigned here: 10
        // If we remove the 10, we have 60 available
        // Requesting 65 should fail
        final error = validateAssignmentQuantity(
          requestedAmount: 65,
          availableAmount: 50,
          currentlyAssigned: 10,
        );

        expect(error, isNotNull);
        expect(error, contains('Insufficient quantity'));
        expect(error, contains('Available: 60'));
        expect(error, contains('Requested: 65'));
      },
    );

    test('allows decreasing assignment (always valid if not negative)', () {
      expect(
        validateAssignmentQuantity(
          requestedAmount: 5,
          availableAmount: 50,
          currentlyAssigned: 10,
        ),
        isNull,
      );
    });

    test('allows setting to 0', () {
      expect(
        validateAssignmentQuantity(
          requestedAmount: 0,
          availableAmount: 50,
          currentlyAssigned: 10,
        ),
        isNull,
      );
    });
  });

  group('assignmentExists', () {
    final assignments = [
      Assignment(id: '1', itemId: 'item1', containerId: 'container1', count: 5),
      Assignment(id: '2', itemId: 'item2', containerId: 'container1', count: 3),
      Assignment(id: '3', itemId: 'item1', containerId: 'container2', count: 2),
    ];

    test('returns true when assignment exists', () {
      expect(
        assignmentExists(
          allAssignments: assignments,
          itemId: 'item1',
          containerId: 'container1',
        ),
        isTrue,
      );
    });

    test('returns false when assignment does not exist', () {
      expect(
        assignmentExists(
          allAssignments: assignments,
          itemId: 'item3',
          containerId: 'container1',
        ),
        isFalse,
      );
    });

    test('returns false when itemId matches but containerId does not', () {
      expect(
        assignmentExists(
          allAssignments: assignments,
          itemId: 'item1',
          containerId: 'container3',
        ),
        isFalse,
      );
    });

    test('returns false when containerId matches but itemId does not', () {
      expect(
        assignmentExists(
          allAssignments: assignments,
          itemId: 'item3',
          containerId: 'container1',
        ),
        isFalse,
      );
    });

    test('returns false for empty assignment list', () {
      expect(
        assignmentExists(
          allAssignments: [],
          itemId: 'item1',
          containerId: 'container1',
        ),
        isFalse,
      );
    });
  });

  group('getTotalAssignedForItem', () {
    final assignments = [
      Assignment(id: '1', itemId: 'item1', containerId: 'container1', count: 5),
      Assignment(id: '2', itemId: 'item2', containerId: 'container1', count: 3),
      Assignment(id: '3', itemId: 'item1', containerId: 'container2', count: 7),
      Assignment(id: '4', itemId: 'item1', containerId: 'container3', count: 2),
    ];

    test('returns total count for item across all containers', () {
      expect(
        getTotalAssignedForItem(allAssignments: assignments, itemId: 'item1'),
        equals(14), // 5 + 7 + 2
      );
    });

    test('returns count for item with single assignment', () {
      expect(
        getTotalAssignedForItem(allAssignments: assignments, itemId: 'item2'),
        equals(3),
      );
    });

    test('returns 0 for item with no assignments', () {
      expect(
        getTotalAssignedForItem(allAssignments: assignments, itemId: 'item99'),
        equals(0),
      );
    });

    test('returns 0 for empty assignment list', () {
      expect(
        getTotalAssignedForItem(allAssignments: [], itemId: 'item1'),
        equals(0),
      );
    });

    test('handles assignments with count 0', () {
      final assignmentsWithZero = [
        ...assignments,
        Assignment(
          id: '5',
          itemId: 'item1',
          containerId: 'container4',
          count: 0,
        ),
      ];

      expect(
        getTotalAssignedForItem(
          allAssignments: assignmentsWithZero,
          itemId: 'item1',
        ),
        equals(14), // Should still be 14 (5 + 7 + 2 + 0)
      );
    });
  });

  group('getTotalAssignedInContainer', () {
    final assignments = [
      Assignment(id: '1', itemId: 'item1', containerId: 'container1', count: 5),
      Assignment(id: '2', itemId: 'item2', containerId: 'container1', count: 3),
      Assignment(id: '3', itemId: 'item3', containerId: 'container1', count: 7),
      Assignment(id: '4', itemId: 'item1', containerId: 'container2', count: 2),
    ];

    test('returns total count for container across all items', () {
      expect(
        getTotalAssignedInContainer(
          allAssignments: assignments,
          containerId: 'container1',
        ),
        equals(15), // 5 + 3 + 7
      );
    });

    test('returns count for container with single assignment', () {
      expect(
        getTotalAssignedInContainer(
          allAssignments: assignments,
          containerId: 'container2',
        ),
        equals(2),
      );
    });

    test('returns 0 for container with no assignments', () {
      expect(
        getTotalAssignedInContainer(
          allAssignments: assignments,
          containerId: 'container99',
        ),
        equals(0),
      );
    });

    test('returns 0 for empty assignment list', () {
      expect(
        getTotalAssignedInContainer(
          allAssignments: [],
          containerId: 'container1',
        ),
        equals(0),
      );
    });

    test('handles assignments with count 0', () {
      final assignmentsWithZero = [
        ...assignments,
        Assignment(
          id: '5',
          itemId: 'item4',
          containerId: 'container1',
          count: 0,
        ),
      ];

      expect(
        getTotalAssignedInContainer(
          allAssignments: assignmentsWithZero,
          containerId: 'container1',
        ),
        equals(15), // Should still be 15 (5 + 3 + 7 + 0)
      );
    });
  });
}
