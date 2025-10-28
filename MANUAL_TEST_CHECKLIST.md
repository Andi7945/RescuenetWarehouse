# Manual Test Checklist - Assignment Service Refactoring

This document provides manual test scenarios to verify the Assignment Service refactoring is working correctly in the application.

## Test Environment Setup

Before testing:
1. Deploy to staging environment or run locally
2. Login with appropriate user credentials
3. Ensure you have test items and containers available

## Test Scenarios

### 1. Item Edit Page - Assignment Tab

**Purpose:** Verify assignment operations from the item detail page work correctly.

**Test Steps:**

1. **Navigate to Item Edit Page**
   - [ ] Go to Items Overview
   - [ ] Select an existing item
   - [ ] Navigate to the "Assignments" tab

2. **Add New Assignment**
   - [ ] Click "Add to Container" button
   - [ ] Select a container from the modal
   - [ ] Enter a quantity (e.g., 5)
   - [ ] Save the assignment
   - [ ] **Expected:** Assignment appears in the list with correct count
   - [ ] **Expected:** Work log is created for the addition

3. **Update Assignment Count**
   - [ ] Find an existing assignment
   - [ ] Change the count to a different positive number (e.g., 10)
   - [ ] Save the change
   - [ ] **Expected:** Assignment count updates in the list
   - [ ] **Expected:** Work log is created with the delta (e.g., +5)

4. **Delete Assignment (by setting count to 0)**
   - [ ] Find an existing assignment
   - [ ] Change the count to 0
   - [ ] Save the change
   - [ ] **Expected:** Assignment is removed from the list
   - [ ] **Expected:** Work log is created showing removal (negative count)

5. **Cancel Assignment Changes**
   - [ ] Start editing an assignment count
   - [ ] Click cancel or navigate away without saving
   - [ ] **Expected:** Changes are not persisted
   - [ ] **Expected:** No work log is created

### 2. Container Assignment Page

**Purpose:** Verify assignment operations from the container-centric view work correctly.

**Test Steps:**

1. **Navigate to Container Assignment Page**
   - [ ] Go to Containers Overview
   - [ ] Select a container
   - [ ] Navigate to assignments view

2. **View Current Assignments**
   - [ ] **Expected:** All items assigned to this container are displayed
   - [ ] **Expected:** Counts are accurate

3. **Add Item to Container**
   - [ ] Click "Add Item" or similar button
   - [ ] Search for and select an item
   - [ ] Enter initial quantity
   - [ ] Confirm
   - [ ] **Expected:** Item appears in container's assignment list
   - [ ] **Expected:** Work log is created

4. **Modify Assignment from Container View**
   - [ ] Change the count of an assigned item
   - [ ] Save the change
   - [ ] **Expected:** Count updates correctly
   - [ ] **Expected:** Work log reflects the change

5. **Remove Item from Container**
   - [ ] Set an assignment count to 0 or use delete action
   - [ ] Confirm
   - [ ] **Expected:** Assignment is removed from container
   - [ ] **Expected:** Work log shows removal

### 3. Search & Assign

**Purpose:** Verify the search and assign flow works correctly.

**Test Steps:**

1. **Search for Items to Assign**
   - [ ] From container assignment page, initiate search
   - [ ] Search by item name or filter
   - [ ] **Expected:** Relevant items are displayed

2. **Assign Item from Search Results**
   - [ ] Select an item from search results
   - [ ] Enter quantity
   - [ ] Confirm assignment
   - [ ] **Expected:** Assignment is created successfully
   - [ ] **Expected:** Work log is created
   - [ ] **Expected:** Item appears in container's assignment list

3. **Prevent Duplicate Assignments**
   - [ ] Try to assign an item that's already assigned to the container
   - [ ] **Expected:** System prevents duplicate or allows updating count
   - [ ] **Expected:** Error message or update flow is clear

### 4. Work Logs

**Purpose:** Verify all assignment operations create appropriate work logs.

**Test Steps:**

1. **Navigate to Work Log Page**
   - [ ] Go to Work Logs view
   - [ ] Filter by recent date range

2. **Verify Assignment Creation Logs**
   - [ ] Create a new assignment (from any page)
   - [ ] Check work logs
   - [ ] **Expected:** Log entry shows:
     - Item name
     - Container name
     - Positive count (quantity added)
     - User who made the change
     - Timestamp

3. **Verify Assignment Update Logs**
   - [ ] Update an assignment count (increase or decrease)
   - [ ] Check work logs
   - [ ] **Expected:** Log entry shows:
     - Item name
     - Container name
     - Delta count (change amount, can be positive or negative)
     - User who made the change
     - Timestamp

4. **Verify Assignment Deletion Logs**
   - [ ] Delete an assignment (set count to 0)
   - [ ] Check work logs
   - [ ] **Expected:** Log entry shows:
     - Item name
     - Container name
     - Negative count (quantity removed)
     - User who made the change
     - Timestamp

5. **Verify Batch Operations**
   - [ ] If bulk update/delete features exist, perform batch operations
   - [ ] Check work logs
   - [ ] **Expected:** Individual log entries for each affected assignment

### 5. Error Handling

**Purpose:** Verify error scenarios are handled gracefully.

**Test Steps:**

1. **Invalid Input Validation**
   - [ ] Try to create assignment with count = 0
   - [ ] **Expected:** Error message or prevented from saving
   - [ ] Try to create assignment with negative count
   - [ ] **Expected:** Error message or prevented from saving

2. **Network Error Simulation**
   - [ ] Disconnect network (if testing locally)
   - [ ] Try to create/update assignment
   - [ ] **Expected:** User-friendly error message
   - [ ] **Expected:** State remains consistent (no partial updates)

3. **Concurrent Updates**
   - [ ] Open same item/container in two browser tabs
   - [ ] Update assignment in both tabs
   - [ ] **Expected:** Changes are handled consistently
   - [ ] **Expected:** No data loss or corruption

### 6. Edge Cases

**Purpose:** Test boundary conditions and special scenarios.

**Test Steps:**

1. **Empty States**
   - [ ] View item with no assignments
   - [ ] **Expected:** Empty state message is displayed
   - [ ] View container with no assignments
   - [ ] **Expected:** Empty state message is displayed

2. **Large Quantities**
   - [ ] Create assignment with large count (e.g., 1000)
   - [ ] **Expected:** System handles correctly
   - [ ] Update to even larger count
   - [ ] **Expected:** Work log shows correct delta

3. **Rapid Successive Updates**
   - [ ] Quickly update assignment count multiple times
   - [ ] **Expected:** All updates are processed
   - [ ] **Expected:** Work logs reflect all changes

## Success Criteria

All test steps should pass with expected results. Any failures should be documented and investigated.

## Notes

- Test with different user roles (Packer, Back Office, Logistics) if applicable
- Test on different browsers (Chrome, Firefox, Safari) if possible
- Report any unexpected behavior or UI issues
- Pay attention to loading states and user feedback during operations

## Reporting Issues

If you encounter any issues during testing:
1. Document the exact steps to reproduce
2. Note the expected vs. actual behavior
3. Include any error messages or console logs
4. Capture screenshots if helpful
5. Report to the development team

---

**Last Updated:** Phase 8 - Assignment Service Refactoring Completion
