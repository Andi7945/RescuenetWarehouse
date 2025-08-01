# Test Specifications for RescuenetWarehouse

This document defines specific test scenarios for each use case to ensure comprehensive coverage and prevent regressions.

## Test Strategy

### Test Types
- **E2E Tests**: Playwright tests simulating complete user workflows
- **Component Tests**: Individual feature validation  
- **Integration Tests**: Cross-feature workflow validation
- **Regression Tests**: Validate specific bug fixes remain resolved

### Test Data Strategy
- Use mock Firebase backend for consistent test environment
- Seed with predictable test data for reliable assertions
- Test both empty states and populated data scenarios

## Test Specifications by Use Case

### UC01: Authentication & Access Control

#### T01.1: Successful Login Flow
**Scenario**: Valid user logs in successfully
- **Given**: User has valid @rescuenet.net email and password
- **When**: User enters credentials and clicks login
- **Then**: User is redirected to main application dashboard
- **Test File**: `authentication.spec.js` (existing)

#### T01.2: Registration and Auto-Redirect  
**Scenario**: New user registration automatically logs them in
- **Given**: User provides valid registration details
- **When**: User completes registration form
- **Then**: User is automatically logged in and redirected to main app
- **Test File**: `authentication.spec.js` (existing)

#### T01.3: Invalid Email Domain Rejection
**Scenario**: Non-rescuenet email is rejected
- **Given**: User attempts registration with non-@rescuenet.net email
- **When**: User submits registration form
- **Then**: System shows appropriate error message
- **Test File**: `authentication.spec.js` (existing)

#### T01.4: Password Reset Flow
**Scenario**: User can reset forgotten password
- **Given**: User forgot their password
- **When**: User clicks forgot password and enters email
- **Then**: Password reset flow is initiated
- **Test File**: `authentication.spec.js` (existing)

### UC02: Item Management

#### T02.1: Item Overview and Navigation
**Scenario**: User can browse and navigate item inventory
- **Given**: System has items in database
- **When**: User navigates to items overview
- **Then**: Items are displayed with basic information
- **Test File**: `item-management.spec.js` (new)

#### T02.2: Item Filtering and Sorting
**Scenario**: User can filter and sort items effectively
- **Given**: Multiple items with different attributes exist
- **When**: User applies filters (location, status, dangerous goods)
- **Then**: Only matching items are displayed
- **And**: Sorting works correctly by name, quantity, expiry date
- **Test File**: `item-management.spec.js` (new)

#### T02.3: Item Creation and Editing
**Scenario**: User can create and modify item details
- **Given**: User has Back Office or Logistics role
- **When**: User creates new item with complete metadata
- **Then**: Item is saved with all fields correct
- **And**: Item appears in overview with proper assignments
- **Test File**: `item-management.spec.js` (new)

#### T02.4: Item Quantity Management
**Scenario**: Item quantities update correctly without random increases
- **Given**: Item has assignments to containers
- **When**: User modifies quantities using increment/decrement
- **Then**: Quantities change predictably within boundaries
- **And**: No random quantity increases occur
- **Test File**: `item-quantity.spec.js` (existing, enhance)

#### T02.5: Dangerous Goods Management
**Scenario**: User can manage dangerous goods classifications
- **Given**: Item requires dangerous goods classification
- **When**: User adds/modifies dangerous goods signs
- **Then**: Classifications are saved and displayed correctly
- **And**: PDF exports include proper dangerous goods documentation
- **Test File**: `dangerous-goods.spec.js` (new)

#### T02.6: Expiry Date Tracking
**Scenario**: System tracks and alerts on item expiry dates
- **Given**: Items have expiry dates set
- **When**: User views item with approaching expiry
- **Then**: Visual indicators show expiry status
- **And**: Expired items are flagged appropriately
- **Test File**: `expiry-tracking.spec.js` (new)

#### T02.7: Bulk Item Import
**Scenario**: User can import items from CSV with validation
- **Given**: User has CSV file with item data
- **When**: User imports CSV file
- **Then**: System shows diff preview of changes
- **And**: User can review and confirm import
- **And**: Invalid data is flagged with clear error messages
- **Test File**: `csv-import.spec.js` (new)

#### T02.8: Item Export and Reporting
**Scenario**: User can export item data in various formats
- **Given**: Items exist in system
- **When**: User initiates export (CSV, PDF)
- **Then**: Export file contains correct data
- **And**: Export respects current filters and sorting
- **Test File**: `item-export.spec.js` (new)

### UC03: Container Management

#### T03.1: Container Overview and Status
**Scenario**: User can view container status and details
- **Given**: Containers exist with various states
- **When**: User navigates to container overview
- **Then**: Containers display with current utilization
- **And**: Visual indicators show capacity status
- **Test File**: `container-management.spec.js` (new)

#### T03.2: Container Creation and Editing
**Scenario**: User can create and modify containers
- **Given**: Container types are configured in system
- **When**: User creates new container with type and location
- **Then**: Container is saved with proper capacity calculations
- **And**: Container appears in overview
- **Test File**: `container-management.spec.js` (new)

#### T03.3: Container Data Persistence
**Scenario**: Container changes persist correctly across sessions
- **Given**: User modifies container details
- **When**: User saves changes and reloads page
- **Then**: All changes are preserved
- **And**: Container type, location, and destination are maintained
- **Test File**: `container-persistence.spec.js` (existing, enhance)

#### T03.4: Container Type Management
**Scenario**: User can manage container types with empty weights
- **Given**: User has admin access to container types
- **When**: User adds/edits container type with empty weight
- **Then**: Changes persist to database correctly
- **And**: Empty weight validation works properly
- **Test File**: `container-types.spec.js` (existing, enhance)

#### T03.5: Container Capacity Validation
**Scenario**: System prevents capacity violations
- **Given**: Container has defined weight/volume limits
- **When**: User attempts to exceed capacity via assignments
- **Then**: System prevents overloading with clear warning
- **And**: Capacity calculations are accurate
- **Test File**: `container-capacity.spec.js` (new)

### UC04: Assignment Management

#### T04.1: Item-to-Container Assignment
**Scenario**: User can assign items to containers
- **Given**: Items and containers exist in system
- **When**: User assigns quantity of item to container
- **Then**: Assignment is created and capacity updated
- **And**: Item shows assignment in overview
- **Test File**: `assignment-management.spec.js` (new)

#### T04.2: Container-Based Assignment View
**Scenario**: User can manage all assignments for a container
- **Given**: Container has existing assignments
- **When**: User views container assignment page
- **Then**: All assigned items are displayed with quantities
- **And**: User can search and add new items
- **And**: User can modify existing assignments
- **Test File**: `assignment-management.spec.js` (new)

#### T04.3: Assignment Quantity Validation
**Scenario**: Assignment quantities are validated correctly
- **Given**: Item has limited available quantity
- **When**: User attempts to assign more than available
- **Then**: System prevents over-assignment with warning
- **And**: Total assignments don't exceed item inventory
- **Test File**: `assignment-validation.spec.js` (new)

#### T04.4: Assignment Duplicate Prevention
**Scenario**: System prevents duplicate assignments
- **Given**: Item is already assigned to container
- **When**: User attempts to create duplicate assignment
- **Then**: System either merges quantities or prevents duplicate
- **And**: No duplicate assignment records are created
- **Test File**: `item-quantity.spec.js` (existing covers this)

### UC05: Deployment Preparation (Packer Workflows)

#### T05.1: Container Verification Workflow
**Scenario**: Packer can verify container contents
- **Given**: Container has assigned items for verification
- **When**: Packer opens container verification view
- **Then**: All assigned items are listed with expected quantities
- **And**: Packer can mark items as verified/missing
- **Test File**: `packer-workflow.spec.js` (new)

#### T05.2: PDF Generation - Packing Lists
**Scenario**: System generates accurate packing lists
- **Given**: Container has verified assignments
- **When**: User generates packing list PDF
- **Then**: PDF contains all items with correct quantities
- **And**: Dangerous goods are properly flagged
- **And**: Container details are accurate
- **Test File**: `pdf-generation.spec.js` (new)

#### T05.3: PDF Generation - Labels and Summaries
**Scenario**: System generates container labels and summaries
- **Given**: Container is ready for deployment
- **When**: User generates labels and summary sheets
- **Then**: Labels contain proper identification and QR codes
- **And**: Summary sheets show weight and capacity info
- **Test File**: `pdf-generation.spec.js` (new)

#### T05.4: Dangerous Goods Documentation
**Scenario**: System generates proper dangerous goods documentation
- **Given**: Container contains items with dangerous goods
- **When**: User generates deployment documentation
- **Then**: Dangerous goods classifications are included
- **And**: Proper warnings and handling instructions are shown
- **Test File**: `dangerous-goods.spec.js` (new)

### UC06: Post-Deployment Processing

#### T06.1: Post-Deployment Inventory Update
**Scenario**: User can update inventory after deployment
- **Given**: Container was deployed and returned
- **When**: User marks items as used/damaged/lost/returned
- **Then**: Inventory quantities are updated correctly
- **And**: Work log entries are created
- **Test File**: `post-deployment.spec.js` (new)

#### T06.2: Container Status Management
**Scenario**: Container status updates through deployment cycle
- **Given**: Container goes through deployment process
- **When**: Status changes from packed → deployed → returned
- **Then**: Status is tracked correctly at each stage
- **And**: Historical status is maintained
- **Test File**: `container-lifecycle.spec.js` (new)

### UC07: Reference Data Management

#### T07.1: Container Types Management with Usage Validation
**Scenario**: Container types can be managed with proper validation
- **Given**: Container types may be in use by containers
- **When**: User attempts to delete container type
- **Then**: System prevents deletion if in use
- **And**: Provides clear feedback about usage
- **Test File**: `reference-data.spec.js` (new)

#### T07.2: Location and Destination Management
**Scenario**: Locations and destinations are manageable
- **Given**: User has admin privileges
- **When**: User adds/edits/deletes locations or destinations
- **Then**: Changes persist correctly
- **And**: Usage validation prevents orphaned references
- **Test File**: `reference-data.spec.js` (new)

### UC08: Reporting & Analytics

#### T08.1: Work Log Reporting
**Scenario**: System generates comprehensive work logs
- **Given**: Various operations have been performed
- **When**: User generates work log report
- **Then**: All operations are listed chronologically
- **And**: User can filter by date range and operation type  
- **Test File**: `reporting.spec.js` (new)

#### T08.2: Container Utilization Analytics
**Scenario**: System provides container utilization insights
- **Given**: Containers have varying utilization levels
- **When**: User views utilization analytics
- **Then**: Capacity usage is accurately calculated and displayed
- **And**: Visual indicators help identify optimization opportunities
- **Test File**: `reporting.spec.js` (new)

### UC09: Data Import/Export

#### T09.1: CSV Import with Diff Preview
**Scenario**: CSV import shows changes before applying
- **Given**: User has CSV file with item updates
- **When**: User uploads CSV file
- **Then**: System shows diff of proposed changes
- **And**: User can review and selectively apply changes
- **Test File**: `csv-import.spec.js` (new)

#### T09.2: Data Export with Filtering
**Scenario**: Export respects current view filters
- **Given**: User has applied filters to item/container view
- **When**: User exports data
- **Then**: Export contains only filtered items
- **And**: Export format matches user selection
- **Test File**: `data-export.spec.js` (new)

## Integration Test Scenarios

### I01: End-to-End Deployment Workflow
**Scenario**: Complete workflow from item creation to deployment
- Create items → Assign to containers → Verify → Generate docs → Deploy → Return processing
- **Test File**: `integration.spec.js` (enhance existing)

### I02: Multi-User Concurrent Operations
**Scenario**: Multiple users working simultaneously
- Validate concurrent edits don't cause data corruption
- **Test File**: `concurrent-operations.spec.js` (new)

### I03: Large Dataset Performance
**Scenario**: System performance with realistic data volumes
- Test with 1000+ items, 100+ containers, complex assignments
- **Test File**: `performance.spec.js` (new)

## Regression Test Scenarios

All existing bug fix tests should be maintained:
- **R01**: Registration redirect bug (existing)
- **R02**: Container persistence bug (existing)  
- **R03**: Item quantity random increase bug (existing)
- **R04**: Container types database persistence (existing)

## Test Implementation Priority

### Phase 1 (High Priority)
- Core item and container management
- Assignment workflows
- Data persistence validation

### Phase 2 (Medium Priority)  
- PDF generation and reporting
- Import/export functionality
- Reference data management

### Phase 3 (Enhancement)
- Performance testing
- Concurrent user scenarios
- Advanced analytics validation