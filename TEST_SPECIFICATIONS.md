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
- All test fixtures located in `test/fixtures/` directory
- Fixed test date: **2024-08-02** for predictable expiry date calculations

### Test Fixtures Overview
All test data is organized by scenario with consistent naming patterns:
- **Item IDs**: `{scenario}_{number}` (e.g., `filter_001`, `exp_002`)
- **User Roles**: Packer, Back Office, Logistics, On Deployment
- **Locations**: Warehouse A, Field Office, Mobile Unit, Warehouse B
- **Test Configuration**: `test/fixtures/test_config.json` maps scenarios to required fixtures

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

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/basic_navigation_items.json`
- **Configuration**: Load via `test_config.json` scenario "T02.1"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **3 items** with varied attributes for navigation testing
  - **Locations**: Warehouse A (2 items), Field Office (1 item) 
  - **Quantities**: Range 50-200 with different availability
  - **Expiry dates**: Mix of future, past, and null values
  - **Dangerous goods**: Mix of "None" and "Class 9"
- **Expected Item Count**: Exactly 3 items displayed
- **Key Test Items**:
  - `item_001`: "First Aid Kit" - Warehouse A, 50 total/35 available
  - `item_002`: "Water Purification Tablets" - Field Office, 200 total/150 available  
  - `item_003`: "Emergency Blankets" - Warehouse A, 100 total/100 available

**Assertions**:
- Item list container is visible on page
- At least 3 test items are displayed (predictable test data)
- Each item shows: name, current location, total quantity, available quantity
- Item names are clickable and lead to detail view
- Navigation breadcrumbs show "Items" as current page
- Search box is present and functional
- Filter controls are visible (location, status, dangerous goods)

#### T02.2: Item Filtering and Sorting
**Scenario**: User can filter and sort items effectively
- **Given**: Multiple items with different attributes exist
- **When**: User applies filters (location, status, dangerous goods)
- **Then**: Only matching items are displayed
- **And**: Sorting works correctly by name, quantity, expiry date
- **Test File**: `item-management.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/filtering_sorting_items.json`
- **Configuration**: Load via `test_config.json` scenario "T02.2"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **5 items** designed for comprehensive filtering/sorting testing
  - **Locations**: Warehouse A (3 items), Field Office (1), Mobile Unit (1)
  - **Dangerous Goods**: Class 3 (2 items), Class 9 (1), None (2)
  - **Availability**: Mixed available/unavailable (filter_002 has 0 available)
  - **Alphabetical Order**: Alcohol → Bandages → Chemical → Disposable → Emergency
- **Filter Test Scenarios**:
  - **Location "Warehouse A"**: Should show 3 items (filter_001, filter_003, filter_005)
  - **Dangerous Goods "Class 3"**: Should show 2 items (filter_001, filter_005) 
  - **Status "Available"**: Should show 4 items (exclude filter_002 with 0 available)
- **Sort Test Data**:
  - **Name ascending**: Alcohol → Emergency (first → last)
  - **Quantity descending**: 500 → 30 (filter_004 → filter_003)
  - **Expiry ascending**: 2023-12-01 → 2026-01-10 (oldest → newest)

**Assertions**:
- Test data includes items with: different locations (Warehouse A, Field Office), dangerous goods (Class 3, Class 9, None), various expiry dates
- Location filter: Select "Warehouse A" → only items with location="Warehouse A" are shown (count exact match)
- Dangerous goods filter: Select "Class 3" → only items with DG classification="Class 3" visible
- Status filter: Select "Available" → only items with available_quantity > 0 shown
- Name sort ascending: First item name alphabetically before last item name
- Quantity sort descending: First item total_quantity ≥ last item total_quantity
- Expiry date sort ascending: First item expiry_date ≤ last item expiry_date (where dates exist)
- Combined filters: Location="Warehouse A" AND DG="None" shows intersection only
- Clear filters button resets to original item count

#### T02.3: Item Creation and Editing
**Scenario**: User can create and modify item details
- **Given**: User has Back Office or Logistics role
- **When**: User creates new item with complete metadata
- **Then**: Item is saved with all fields correct
- **And**: Item appears in overview with proper assignments
- **Test File**: `item-management.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/creation_editing_items.json`, `test/fixtures/items/containers.json`
- **Configuration**: Load via `test_config.json` scenario "T02.3"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has create/edit permissions
- **Test Data Summary**:
  - **2 items**: 1 editable without assignments, 1 with assignments (cannot delete)
  - **Supporting container**: `container_001` for assignment testing
- **Key Test Items**:
  - **`edit_001`**: "Test Medical Kit" - Warehouse A, 25 total/25 available, no assignments (can edit/delete)
  - **`assigned_001`**: "Assigned Item" - Field Office, 50 total/20 available, has 30 assigned to container_001 (cannot delete)
- **Form Validation Test Cases**:
  - **Create New Item**: Use "Test Bandages", 100 pieces, Warehouse A
  - **Edit Existing**: Change edit_001 name to "Updated Bandages", quantity 25→150
  - **Delete Protection**: assigned_001 should show error when delete attempted
- **Reference Data Available**: All locations, units, dangerous goods from fixtures

**Assertions**:
- Create button is visible and clickable for authorized roles
- New item form contains all required fields: name, description, location, quantity, unit, expiry date
- Form validation: Empty name shows error, invalid quantity shows error, past expiry date shows warning
- Save new item with test data: name="Test Bandages", quantity=100, unit="pieces", location="Warehouse A"
- After save: Redirect to item detail page showing exact entered data
- Item appears in main list with correct name="Test Bandages" and quantity=100
- Edit existing item: Change name to "Updated Bandages" → save → verify name changed in detail view and list
- Edit quantity from 100 to 150 → verify available_quantity also updates to 150
- Delete item (if no assignments) → confirm item removed from list
- Cannot delete item with active assignments → error message displayed

#### T02.4: Item Quantity Management
**Scenario**: Item quantities update correctly without random increases
- **Given**: Item has assignments to containers
- **When**: User modifies quantities using increment/decrement
- **Then**: Quantities change predictably within boundaries
- **And**: No random quantity increases occur
- **Test File**: `item-quantity.spec.js` (existing, enhance)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/quantity_management_items.json`, `test/fixtures/items/containers.json`
- **Configuration**: Load via `test_config.json` scenario "T02.4"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **1 item** with precise quantity setup for mathematical validation
  - **1 container** linked via assignment
  - **Exact quantities**: 100 total, 30 assigned, 70 available (math must be perfect)
- **Key Test Setup**:
  - **`qty_001`**: "Quantity Test Item" - Warehouse A, 100 pieces total
  - **`container_qty_001`**: "Test Container QTY" - Standard Box type
  - **`assignment_qty_001`**: Links qty_001 to container_qty_001 with quantity 30
- **Critical Validation Points**:
  - **Initial State**: 100 total = 30 assigned + 70 available
  - **After increment**: 100 total = 31 assigned + 69 available
  - **After decrement**: 100 total = 29 assigned + 71 available
  - **Boundary**: Cannot assign more than 70 available
  - **Math invariant**: assigned + available = total (always 100)

**Assertions**:
- Test item starts with total_quantity=100, assigned_quantity=30, available_quantity=70
- Click increment on assignment: assigned_quantity becomes 31, available_quantity becomes 69, total_quantity remains 100
- Click decrement on assignment: assigned_quantity becomes 29, available_quantity becomes 71, total_quantity remains 100
- Attempt to assign more than available (70): Error message displayed, assignment stays at valid value
- Direct quantity input field: Enter 25 → press enter → assigned_quantity=25, available_quantity=75
- Invalid input: Enter negative number → error displayed, quantity unchanged
- Invalid input: Enter non-numeric → error displayed, quantity unchanged
- Multiple rapid clicks: Quantity changes match exact number of clicks (no race conditions)
- Page refresh after changes: All quantities persist with correct values from before refresh
- After 10 random operations: total_quantity never exceeds original value, assigned+available always equals total

#### T02.5: Dangerous Goods Management
**Scenario**: User can manage dangerous goods classifications
- **Given**: Item requires dangerous goods classification
- **When**: User adds/modifies dangerous goods signs
- **Then**: Classifications are saved and displayed correctly
- **And**: PDF exports include proper dangerous goods documentation
- **Test File**: `dangerous-goods.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/dangerous_goods_items.json`, `test/fixtures/reference_data/dangerous_goods.json`
- **Configuration**: Load via `test_config.json` scenario "T02.5"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`)
- **Test Data Summary**:
  - **3 items** covering different dangerous goods scenarios
  - **Complete DG reference data**: All UN Class 1-9 + None with descriptions and symbols
- **Key Test Items**:
  - **`dg_001`**: "Fuel Additive" - None classification (test adding DG)
  - **`dg_002`**: "Cleaning Solvent" - Class 3 classification (test modifying DG)
  - **`dg_003`**: "Battery Acid" - Class 8 classification (test corrosive materials)
- **Dangerous Goods Test Scenarios**:
  - **Add Classification**: dg_001 None → Class 3 "Flammable Liquids"
  - **Modify Classification**: dg_002 Class 3 → Class 8 "Corrosive"
  - **Remove Classification**: dg_003 Class 8 → None
  - **Filter Testing**: Each class should show only matching items
- **Reference Data Features**:
  - **Complete Classifications**: Class 1-9 with names, descriptions, symbols
  - **Visual Indicators**: Each class has color coding and emoji symbols
  - **Handling Instructions**: Detailed safety procedures for each class

**Assertions**:
- Dangerous goods dropdown shows all UN classes: Class 1-9 and "None"
- Select "Class 3 - Flammable Liquids" → save → item detail shows "Class 3" badge
- Item list view shows DG icon for items with dangerous goods classification
- Filter by dangerous goods shows only items with that specific classification
- Add multiple DG signs to single item → all signs displayed in item detail
- Remove dangerous goods classification → no DG badge shown, item excluded from DG filter
- PDF generation test: Item with Class 3 → PDF contains warning symbol and "Class 3" text
- PDF packing list: DG items listed separately with prominent warnings
- Search for "flammable" finds items with Class 3 classification
- Dangerous goods validation: Cannot set invalid combination of incompatible classes

#### T02.6: Expiry Date Tracking
**Scenario**: System tracks and alerts on item expiry dates
- **Given**: Items have expiry dates set
- **When**: User views item with approaching expiry
- **Then**: Visual indicators show expiry status
- **And**: Expired items are flagged appropriately
- **Test File**: `expiry-tracking.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/expiry_tracking_items.json`
- **Configuration**: Load via `test_config.json` scenario "T02.6" 
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Fixed Test Date**: "2024-08-02" (for predictable expiry calculations)
- **Test Data Summary**:
  - **4 items** covering all expiry states relative to test date
  - **Expiry categories**: Expired, Expiring Soon, Future, No Expiry
- **Key Test Items** (relative to 2024-08-02):
  - **`exp_001`**: "Expired Medication" - expired 2024-07-01 (32 days ago)
  - **`exp_002`**: "Expiring Soon Bandages" - expiring 2024-08-20 (18 days future, within 30-day window)
  - **`exp_003`**: "Future Expiry Supplies" - future 2025-12-31 (516 days future)
  - **`exp_004`**: "No Expiry Equipment" - null expiry date
- **Expected Visual Indicators**:
  - **Expired**: Red badge "EXPIRED" (exp_001)
  - **Expiring Soon**: Yellow/orange badge "EXPIRES SOON" (exp_002)
  - **Future**: Green badge or no warning (exp_003)
  - **No Expiry**: No expiry indicator (exp_004)
- **Filter Test Results**:
  - **"Expired" filter**: Should show 1 item (exp_001)
  - **"Expiring Soon" filter**: Should show 1 item (exp_002)
  - **Dashboard count**: Should show "1 expired item"

**Assertions**:
- Test data includes: expired item (date < today), expiring soon (date within 30 days), future expiry (date > 30 days from today)
- Expired item shows red warning badge with "EXPIRED" text
- Expiring soon item shows yellow/orange warning badge with "EXPIRES SOON" text
- Future expiry item shows green badge or no warning
- Item list sortable by expiry date (earliest first shows expired items at top)
- Filter by "Expiring Soon" shows only items expiring within 30 days
- Filter by "Expired" shows only items with date < today
- Item detail page shows exact expiry date in readable format (e.g., "March 15, 2024")
- Dashboard/summary shows count of expired items (exact number from test data)
- Cannot assign expired items to new containers → warning message displayed
- Bulk expiry report shows all items grouped by expiry status

#### T02.7: Bulk Item Import
**Scenario**: User can import items from CSV with validation
- **Given**: User has CSV file with item data
- **When**: User imports CSV file
- **Then**: System shows diff preview of changes
- **And**: User can review and confirm import
- **And**: Invalid data is flagged with clear error messages
- **Test File**: `csv-import.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/import_export_items.json`, `test/fixtures/csv_files/`
- **Configuration**: Load via `test_config.json` scenario "T02.7"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has import permissions
- **Test Data Summary**:
  - **1 existing item** for update testing during import
  - **2 CSV files**: valid and invalid for comprehensive testing
- **Existing Item for Update**:
  - **`import_existing_001`**: "Medical Bandages" - Warehouse A, 100→150 (quantity update test)
- **CSV Test Files**:
  - **`valid_import.csv`**: 3 rows (1 update + 2 new items)
    - Updates: "Medical Bandages" 100→150 pieces, expiry 2025-06-30→2025-12-31
    - New: "Antiseptic Wipes" (Class 3), "Emergency Blankets" (no expiry)
  - **`invalid_import.csv`**: 4 rows (3 invalid + 1 valid)
    - Row 1: Missing name (empty)
    - Row 2: Invalid quantity (-10)
    - Row 3: Invalid location ("Unknown Location")
    - Row 4: Valid item for partial import testing
- **Expected Import Results**:
  - **Valid CSV**: Preview shows "2 new items to create, 1 existing item to update"
  - **Invalid CSV**: 3 validation errors flagged, 1 valid row available for import

**Assertions**:
- Import button visible for authorized users (Back Office, Logistics roles)
- File upload accepts .csv files, rejects other formats with clear error
- Valid CSV with 3 items shows preview table with 3 rows
- Preview shows: "2 new items to create, 1 existing item to update"
- Each preview row shows old vs new values for changed fields
- Invalid data validation: Missing required field → row marked with error icon and message
- Invalid data validation: Invalid quantity → specific error "Quantity must be a positive number"
- Invalid data validation: Invalid location → error "Location 'XYZ' does not exist"
- User can uncheck rows to exclude from import
- Confirm import with 2 valid rows → success message "2 items imported successfully"
- After import: Navigate to items list → verify new items appear with correct data
- Import duplicate items (same name) → shows merge options or skip duplicates

#### T02.8: Item Export and Reporting
**Scenario**: User can export item data in various formats
- **Given**: Items exist in system
- **When**: User initiates export (CSV, PDF)
- **Then**: Export file contains correct data
- **And**: Export respects current filters and sorting
- **Test File**: `item-export.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/items/import_export_items.json`, `test/fixtures/csv_files/export_expected.csv`
- **Configuration**: Load via `test_config.json` scenario "T02.8"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`) - has export permissions
- **Test Data Summary**:
  - **4 items** with alphabetically ordered names for sort testing
  - **Mixed attributes**: locations, dangerous goods, expiry dates
  - **Permission testing**: Compare Back Office vs Packer export access
- **Key Test Items** (alphabetical order):
  - **`export_001`**: "Alpha Medical Kit" - Warehouse A, 25/20, kits, 2025-03-15, None
  - **`export_002`**: "Beta Supplies" - Field Office, 100/75, pieces, 2024-12-31, Class 3
  - **`export_003`**: "Zulu Equipment" - Warehouse A, 10/10, units, null expiry, Class 9
  - **`import_existing_001`**: "Medical Bandages" - for complete dataset
- **Export Test Scenarios**:
  - **No filters**: Should export all 4 items
  - **Location filter "Warehouse A"**: Should export 2 items (export_001, export_003)
  - **Name sort ascending**: "Alpha" first, "Zulu" last
- **Expected CSV Format**:
  - **Headers**: "Name,Description,Location,Total Quantity,Available Quantity,Unit,Expiry Date,Dangerous Goods"
  - **Reference file**: `export_expected.csv` shows exact format
- **Permission Testing**:
  - **Back Office**: Can export (success)
  - **Packer role**: Cannot export (should show access denied)

**Assertions**:
- Export dropdown shows available formats: CSV, PDF
- No filters applied: CSV export contains all test items (exact count matches UI)
- CSV export headers match: Name, Description, Location, Total Quantity, Available Quantity, Unit, Expiry Date, Dangerous Goods
- CSV export data: First row contains correct values for known test item
- Apply location filter "Warehouse A" → export → CSV contains only filtered items (count matches filtered UI)
- Sort by name ascending → export → CSV first row has alphabetically first item name
- PDF export generates file download (check file size > 0 bytes)
- PDF export contains item summary table with correct total count
- Export filename includes timestamp (e.g., "items_export_2024-03-15.csv")
- Large dataset (100+ items): Export completes without timeout
- Export respects user permissions (Packer role cannot export vs Back Office can export)

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

## Test Fixtures Implementation Guide

### Loading Test Data
Each test scenario should load its fixtures using the configuration mapping:

```javascript
// Example: Loading fixtures for T02.1
const testConfig = require('../fixtures/test_config.json');
const scenario = testConfig.test_scenarios['T02.1'];

// Load required fixtures
for (const fixture of scenario.fixtures) {
  await loadFixture(fixture);
}

// Authenticate as specified user
await authenticateAs(scenario.auth_user);
```

### Fixture File Structure
- **Items**: `test/fixtures/items/{scenario}_items.json`
- **Users**: `test/fixtures/users/test_users.json`
- **Reference Data**: `test/fixtures/reference_data/{type}.json`
- **CSV Files**: `test/fixtures/csv_files/{purpose}.csv`

### Test Data Characteristics

#### Predictable Data
- **Fixed IDs**: Consistent patterns for reliable assertions
- **Alphabetical Names**: For sorting test validation
- **Mathematical Precision**: Exact quantities for boundary testing
- **Fixed Test Date**: 2024-08-02 for expiry calculations

#### Comprehensive Coverage
- **All User Roles**: Packer, Back Office, Logistics, On Deployment
- **All Dangerous Goods**: Complete UN Class 1-9 + None
- **All Expiry States**: Expired, expiring soon, future, no expiry
- **Edge Cases**: Zero quantities, null values, validation errors

#### Real-world Scenarios
- **Realistic Names**: Medical supplies, emergency equipment
- **Proper Classifications**: Accurate dangerous goods assignments
- **Logical Relationships**: Items assigned to appropriate containers
- **Business Rules**: Inventory math, capacity constraints

### Key Validation Points
- **Quantity Math**: assigned + available = total (always)
- **Date Logic**: Relative to fixed test date 2024-08-02
- **Permission Testing**: Different capabilities per user role
- **Data Integrity**: All foreign key relationships valid
- **Business Rules**: Cannot delete assigned items, capacity limits

### Maintenance Guidelines
- **Consistent Naming**: Follow `{scenario}_{number}` pattern
- **Update Configuration**: Add new scenarios to test_config.json
- **Validate Data**: Ensure all relationships and constraints are valid
- **Document Changes**: Update this specification when adding fixtures