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

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/users/authentication_users.json`
- **Configuration**: Load via `test_config.json` scenario "T01.1"
- **Test Data Summary**:
  - **4 test users**: One for each role with valid credentials
- **Key Test Users**:
  - **`auth_packer_001`**: "packer.test@rescuenet.net" - Packer role
  - **`auth_backoffice_001`**: "backoffice.test@rescuenet.net" - Back Office role
  - **`auth_logistics_001`**: "logistics.test@rescuenet.net" - Logistics role
  - **`auth_deployment_001`**: "deployment.test@rescuenet.net" - On Deployment role
- **Login Test Scenarios**:
  - **Valid Credentials**: Use auth_backoffice_001 with correct password
  - **Role Verification**: Each role sees appropriate dashboard content
  - **Session Persistence**: Login remains valid across page refreshes

**Assertions**:
- Login page displays email and password fields with "Login" button
- Enter valid credentials: "backoffice.test@rescuenet.net" and correct password
- Click "Login" button → success authentication without errors
- Redirect to main dashboard URL (e.g., "/dashboard" or "/items")
- Dashboard shows user-specific content based on role (Back Office sees item management)
- User menu/profile shows logged-in user: "Logged in as: backoffice.test@rescuenet.net"
- Navigation menu shows role-appropriate options (Back Office can see Items, Containers)
- Page refresh maintains login session: No redirect back to login page
- Logout functionality: Click logout → redirected to login page
- Session security: Direct access to protected pages requires authentication

#### T01.2: Registration and Auto-Redirect  
**Scenario**: New user registration automatically logs them in
- **Given**: User provides valid registration details
- **When**: User completes registration form
- **Then**: User is automatically logged in and redirected to main app
- **Test File**: `authentication.spec.js` (existing)

**Prerequisites**:
- **Test Fixtures**: None required (creates new user during test)
- **Configuration**: Load via `test_config.json` scenario "T01.2"
- **Test Data Summary**:
  - **New user data**: Generated during test with unique email
- **Registration Test Data**:
  - **Email**: "newuser.test@rescuenet.net" (unique for each test run)
  - **Password**: "TestPassword123!" (meets security requirements)
  - **Full Name**: "Test User Registration"
  - **Role**: "Back Office" (default role for new registrations)
- **Registration Workflow Steps**:
  - **Form Completion**: Fill all required registration fields
  - **Email Validation**: Verify @rescuenet.net domain requirement
  - **Password Security**: Test password strength requirements
  - **Auto-Login**: Verify immediate authentication after registration
  - **Redirect**: Confirm redirect to main application

**Assertions**:
- Registration page shows form fields: email, password, confirm password, full name
- Email field validation: Only @rescuenet.net emails accepted
- Password validation: Must meet complexity requirements (length, special chars)
- Enter valid registration: "newuser.test@rescuenet.net", strong password, "Test User"
- Password confirmation: Enter same password in confirm field
- Click "Register" button → registration succeeds without errors
- Automatic login: User immediately logged in after successful registration
- Redirect to main app: No manual login required, goes directly to dashboard
- User profile shows new user: "Logged in as: newuser.test@rescuenet.net"
- Default role assignment: New user has "Back Office" role permissions
- Registration creates audit log: New user registration recorded in work log

#### T01.3: Invalid Email Domain Rejection
**Scenario**: Non-rescuenet email is rejected
- **Given**: User attempts registration with non-@rescuenet.net email
- **When**: User submits registration form
- **Then**: System shows appropriate error message
- **Test File**: `authentication.spec.js` (existing)

**Prerequisites**:
- **Test Fixtures**: None required (validation testing)
- **Configuration**: Load via `test_config.json` scenario "T01.3"
- **Test Data Summary**:
  - **Invalid email addresses**: Various non-@rescuenet.net domains for testing
- **Invalid Email Test Cases**:
  - **Generic Domain**: "user@gmail.com"
  - **Corporate Domain**: "user@company.com"
  - **Similar Domain**: "user@rescuenet.org" (wrong TLD)
  - **Typo Domain**: "user@rescuenet.net" (missing 't')
  - **Empty Email**: "" (blank field)
- **Email Validation Rules**:
  - **Domain Requirement**: Must end with "@rescuenet.net"
  - **Format Validation**: Must be valid email format
  - **Case Sensitivity**: Should accept "User@RescueNet.NET" (case insensitive)
- **Error Message Testing**:
  - **Clear Feedback**: Specific error messages for different validation failures
  - **User Guidance**: Instructions on how to correct the error

**Assertions**:
- Registration form email field has placeholder text indicating @rescuenet.net requirement
- Enter invalid email "user@gmail.com" → error message appears immediately or on blur
- Error message text: "Email must be from the @rescuenet.net domain"
- Try to submit form with invalid email → form validation prevents submission
- Submit button disabled or form shows validation error before submission
- Try "user@rescuenet.org" → error "Email must end with @rescuenet.net"
- Try "user@rescunet.net" → error for typo in domain name
- Empty email field → error "Email is required"
- Invalid email format "notanemail" → error "Please enter a valid email address"
- Valid case variations: "User@RescueNet.NET" should be accepted (case insensitive)
- Error styling: Invalid email field highlighted with red border or error styling
- Error clearance: Correct email entry removes error message and styling

#### T01.4: Password Reset Flow
**Scenario**: User can reset forgotten password
- **Given**: User forgot their password
- **When**: User clicks forgot password and enters email
- **Then**: Password reset flow is initiated
- **Test File**: `authentication.spec.js` (existing)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/users/password_reset_users.json`
- **Configuration**: Load via `test_config.json` scenario "T01.4"
- **Test Data Summary**:
  - **Existing user**: For password reset testing with known email
- **Password Reset Test User**:
  - **`reset_user_001`**: "passwordreset.test@rescuenet.net" - existing user account
- **Password Reset Workflow Steps**:
  - **Forgot Password Link**: Click "Forgot Password?" on login page
  - **Email Entry**: Enter registered email address
  - **Reset Request**: Submit password reset request
  - **Email Verification**: Confirm reset email sent (simulated in test)
  - **New Password**: Set new password via reset link
  - **Login Verification**: Confirm login with new password
- **Password Reset Validation**:
  - **Email Validation**: Only registered emails can request reset
  - **Security**: Reset links expire after reasonable time
  - **Password Requirements**: New password must meet security standards

**Assertions**:
- Login page shows "Forgot Password?" link prominently
- Click "Forgot Password?" → navigates to password reset page
- Password reset page shows email input field and "Send Reset Link" button
- Enter valid registered email: "passwordreset.test@rescuenet.net"
- Click "Send Reset Link" → success message "Password reset link sent to your email"
- Enter unregistered email → error message "No account found with this email address"
- Enter invalid email format → error "Please enter a valid email address"
- Simulated email verification: Test framework confirms reset email would be sent
- Password reset link simulation: Navigate to reset form with valid token
- New password form: Shows password and confirm password fields
- New password validation: Must meet security requirements (length, complexity)
- Enter new password and confirmation → save → success message "Password updated successfully"
- Automatic redirect to login page after successful password reset
- Login with new password → successfully authenticates and accesses dashboard
- Old password invalidated: Cannot login with previous password

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

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/containers/overview_status_containers.json`, `test/fixtures/items/container_items.json`
- **Configuration**: Load via `test_config.json` scenario "T03.1"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **4 containers** with different utilization levels and states
  - **6 items** assigned across containers to test capacity calculations
  - **3 container types**: Standard Box, Large Box, Pallet with different capacities
- **Key Test Containers**:
  - **`container_status_001`**: "Empty Container" - Standard Box, no assignments (0% utilization)
  - **`container_status_002`**: "Half Full Container" - Large Box, 50% weight capacity used
  - **`container_status_003`**: "Near Full Container" - Standard Box, 85% weight capacity used
  - **`container_status_004`**: "Overweight Container" - Standard Box, 105% capacity (over limit warning)
- **Capacity Test Scenarios**:
  - **Empty**: 0 items, 0kg weight (Green indicator)
  - **Moderate**: 3 items, 25kg/50kg capacity (Yellow indicator)
  - **Near Full**: 5 items, 42.5kg/50kg capacity (Orange indicator)
  - **Over Capacity**: 6 items, 52.5kg/50kg capacity (Red warning)

**Assertions**:
- Container overview page shows grid/list of all test containers (count = 4)
- Each container displays: name, type, current location, destination, utilization percentage
- Empty container shows "0%" utilization with green status indicator
- Half full container shows "50%" utilization with yellow status indicator  
- Near full container shows "85%" utilization with orange status indicator
- Overweight container shows "105%" utilization with red warning indicator and "OVER CAPACITY" badge
- Weight calculations: Container weight = sum of (assigned_quantity × item_weight) for all assigned items
- Volume calculations: Container volume = sum of (assigned_quantity × item_volume) for all assigned items
- Capacity status formula: (used_weight / max_weight) × 100% = displayed percentage
- Container status filters: "Empty" shows 1 container, "Over Capacity" shows 1 container
- Click container name → navigates to container detail page showing assignments
- Sort by utilization percentage: Empty (0%) → Overweight (105%)

#### T03.2: Container Creation and Editing
**Scenario**: User can create and modify containers
- **Given**: Container types are configured in system
- **When**: User creates new container with type and location
- **Then**: Container is saved with proper capacity calculations
- **And**: Container appears in overview
- **Test File**: `container-management.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/containers/creation_editing_containers.json`, `test/fixtures/reference_data/container_types.json`, `test/fixtures/reference_data/locations.json`
- **Configuration**: Load via `test_config.json` scenario "T03.2"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has create/edit permissions
- **Test Data Summary**:
  - **2 containers**: 1 editable without assignments, 1 with assignments (edit restrictions)
  - **3 container types**: Standard Box (50kg/0.5m³), Large Box (100kg/1.0m³), Pallet (500kg/2.0m³)
  - **4 locations**: Warehouse A, Field Office, Mobile Unit, Warehouse B
- **Key Test Containers**:
  - **`edit_container_001`**: "Test Container Alpha" - Standard Box, Warehouse A, no assignments (can edit/delete)
  - **`assigned_container_001`**: "Assigned Container Beta" - Large Box, Field Office, has 5 items assigned (cannot delete)
- **Form Validation Test Cases**:
  - **Create New**: "Test Container Gamma", Pallet type, Warehouse B destination
  - **Edit Existing**: Change edit_container_001 name to "Updated Container Alpha", type to Large Box
  - **Delete Protection**: assigned_container_001 should show error when delete attempted
- **Reference Data Validation**:
  - **Container Types**: All types available in dropdown with capacity info
  - **Locations**: All locations available for current location and destination

**Assertions**:
- Create button visible and clickable for authorized roles (Back Office, Logistics)
- New container form contains required fields: name, container type, current location, destination
- Container type dropdown shows all available types with capacity details (e.g., "Standard Box - 50kg, 0.5m³")
- Location dropdowns populated with all test locations (Warehouse A, Field Office, Mobile Unit, Warehouse B)
- Form validation: Empty name shows error "Container name is required"
- Form validation: Missing container type shows error "Container type must be selected"
- Create new container: name="Test Container Gamma", type="Pallet", location="Warehouse B"
- After save: Redirect to container detail page showing exact entered data
- Container appears in main list with correct name and type
- Edit existing container: Change name to "Updated Container Alpha" → save → verify name changed
- Edit container type from "Standard Box" to "Large Box" → verify capacity limits updated
- Edit location from "Warehouse A" to "Mobile Unit" → verify location updated in detail and list views
- Delete container (if no assignments): Confirm dialog → container removed from list
- Cannot delete container with assignments: Error message "Cannot delete container with active assignments"
- Save validates destination different from current location: Warning if same location selected

#### T03.3: Container Data Persistence
**Scenario**: Container changes persist correctly across sessions
- **Given**: User modifies container details
- **When**: User saves changes and reloads page
- **Then**: All changes are preserved
- **And**: Container type, location, and destination are maintained
- **Test File**: `container-persistence.spec.js` (existing, enhance)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/containers/persistence_containers.json`, `test/fixtures/reference_data/container_types.json`
- **Configuration**: Load via `test_config.json` scenario "T03.3"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **1 container** specifically for persistence testing with known initial values
  - **Complete reference data** for container types and locations
- **Key Test Container**:
  - **`persist_001`**: "Persistence Test Container" - Initial: Standard Box, Warehouse A → Field Office
- **Persistence Test Scenarios**:
  - **Name Change**: "Persistence Test Container" → "Updated Persistence Container"
  - **Type Change**: Standard Box (50kg capacity) → Large Box (100kg capacity)
  - **Location Change**: Warehouse A → Mobile Unit
  - **Destination Change**: Field Office → Warehouse B
- **Expected Final State**: 
  - **Name**: "Updated Persistence Container"
  - **Type**: Large Box with 100kg/1.0m³ capacity
  - **Current Location**: Mobile Unit
  - **Destination**: Warehouse B

**Assertions**:
- Initial container state: name="Persistence Test Container", type="Standard Box", location="Warehouse A", destination="Field Office"
- Edit container name to "Updated Persistence Container" → save → reload page → name persists as "Updated Persistence Container"
- Change container type from "Standard Box" to "Large Box" → save → reload → type persists with new capacity limits (100kg)
- Change current location from "Warehouse A" to "Mobile Unit" → save → reload → location persists as "Mobile Unit"
- Change destination from "Field Office" to "Warehouse B" → save → reload → destination persists as "Warehouse B"
- All changes made in single session: Edit all fields → save once → reload → all changes persist simultaneously
- Browser refresh retains all data: No temporary UI state affects persisted values
- Navigate away and return: Go to items page → return to containers → all data still correct
- Multiple edit sessions: Edit → reload → edit again → reload → all cumulative changes preserved
- Database integrity: Container ID remains same, only modified fields change, timestamps update appropriately

#### T03.4: Container Type Management
**Scenario**: User can manage container types with empty weights
- **Given**: User has admin access to container types
- **When**: User adds/edits container type with empty weight
- **Then**: Changes persist to database correctly
- **And**: Empty weight validation works properly
- **Test File**: `container-types.spec.js` (existing, enhance)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/reference_data/container_types_management.json`, `test/fixtures/containers/type_usage_containers.json`
- **Configuration**: Load via `test_config.json` scenario "T03.4"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has admin permissions for reference data
- **Test Data Summary**:
  - **3 container types**: 2 editable, 1 in use (cannot delete)
  - **2 containers**: Using container types to test deletion protection
- **Key Test Container Types**:
  - **`type_edit_001`**: "Editable Box" - 25kg max, 0.3m³, 2kg empty weight, not in use (can edit/delete)
  - **`type_edit_002`**: "Test Crate" - 75kg max, 0.8m³, 5kg empty weight, not in use (can edit/delete)  
  - **`type_in_use_001`**: "Used Box Type" - 50kg max, 0.5m³, 3kg empty weight, used by container_usage_001 (cannot delete)
- **Container Type Test Scenarios**:
  - **Create New**: "Custom Pallet", 800kg max weight, 3.0m³ max volume, 15kg empty weight
  - **Edit Existing**: Change type_edit_001 empty weight 2kg → 3.5kg, max weight 25kg → 30kg
  - **Delete Protection**: type_in_use_001 should show error when delete attempted
  - **Validation**: Empty weight cannot exceed max weight, negative values rejected
- **Empty Weight Calculations**:
  - **Available Capacity**: max_weight - empty_weight = usable capacity for items
  - **Example**: Custom Pallet: 800kg - 15kg = 785kg available for items

**Assertions**:
- Container types page shows all test types with specifications (count = 3)
- Each type displays: name, max weight, max volume, empty weight, usage count
- Create button visible for admin users (Logistics role)
- New container type form: name="Custom Pallet", max_weight=800, max_volume=3.0, empty_weight=15
- Form validation: Empty weight > max weight → error "Empty weight cannot exceed maximum weight"
- Form validation: Negative empty weight → error "Empty weight must be positive"
- Form validation: Missing name → error "Container type name is required"
- Save new type → appears in type list with all correct specifications
- Edit existing type: Change empty weight from 2kg to 3.5kg → save → verify updated in list and detail
- Edit existing type: Change max weight from 25kg to 30kg → verify available capacity updates (30-3.5=26.5kg)
- Delete unused type: Confirm dialog → type removed from list and no longer available in container creation
- Cannot delete type in use: Error message "Cannot delete container type that is in use by existing containers"
- Usage tracking: Type used by 1 container shows "Used by 1 container(s)" in detail view
- After type update: Existing containers using type retain link but get updated capacity calculations

#### T03.5: Container Capacity Validation
**Scenario**: System prevents capacity violations
- **Given**: Container has defined weight/volume limits
- **When**: User attempts to exceed capacity via assignments
- **Then**: System prevents overloading with clear warning
- **And**: Capacity calculations are accurate
- **Test File**: `container-capacity.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/containers/capacity_validation_containers.json`, `test/fixtures/items/capacity_test_items.json`
- **Configuration**: Load via `test_config.json` scenario "T03.5"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **2 containers** with precise capacity limits for mathematical validation
  - **5 items** with known weights/volumes for capacity testing
- **Key Test Setup**:
  - **`capacity_container_001`**: "Small Test Container" - Standard Box, 50kg max, 0.5m³ max, currently 40kg used
  - **`capacity_container_002`**: "Volume Test Container" - Large Box, 100kg max, 1.0m³ max, currently 0.8m³ used
- **Capacity Test Items**:
  - **`heavy_item_001`**: "Heavy Equipment" - 15kg, 0.1m³ per unit (weight boundary test)
  - **`bulky_item_001`**: "Bulky Supplies" - 5kg, 0.3m³ per unit (volume boundary test)
  - **`light_item_001`**: "Light Materials" - 2kg, 0.05m³ per unit (safe assignment)
  - **`very_heavy_001`**: "Very Heavy Item" - 25kg, 0.1m³ per unit (exceeds remaining capacity)
  - **`very_bulky_001`**: "Very Bulky Item" - 3kg, 0.4m³ per unit (exceeds remaining volume)
- **Capacity Test Scenarios**:
  - **Weight Limit**: Container has 10kg remaining (50kg - 40kg), attempt to assign 15kg item
  - **Volume Limit**: Container has 0.2m³ remaining (1.0m³ - 0.8m³), attempt to assign 0.3m³ item
  - **Safe Assignment**: Within both weight and volume limits
  - **Edge Case**: Exactly at capacity limit (no warning, should succeed)

**Assertions**:
- Container capacity display: Shows "40kg / 50kg (80%)" and "0.3m³ / 0.5m³ (60%)" for current utilization
- Attempt to assign heavy_item_001 (15kg) to capacity_container_001 → error "Would exceed weight capacity by 5kg"
- Attempt to assign bulky_item_001 (0.3m³) to capacity_container_002 → error "Would exceed volume capacity by 0.1m³"
- Attempt to assign very_heavy_001 (25kg) → error "Cannot assign: item weight exceeds remaining capacity"
- Assign light_item_001 (2kg, 0.05m³) successfully → capacity updates to "42kg / 50kg (84%)"
- Assign exactly 10kg item to container with 10kg remaining → succeeds with "50kg / 50kg (100%)" warning
- Multiple items: Assign 3 × light_item_001 (6kg total) → capacity becomes "46kg / 50kg (92%)"
- Capacity validation in real-time: As user types quantity, warning appears before save attempt
- Weight + volume validation: Item passes weight check but fails volume check → blocked with volume error
- Assignment removal: Remove 10kg assignment → capacity updates immediately to show freed space
- Bulk assignment validation: Select 5 heavy items → error "Total weight 75kg exceeds container capacity 50kg"

### UC04: Assignment Management

#### T04.1: Item-to-Container Assignment
**Scenario**: User can assign items to containers
- **Given**: Items and containers exist in system
- **When**: User assigns quantity of item to container
- **Then**: Assignment is created and capacity updated
- **And**: Item shows assignment in overview
- **Test File**: `assignment-management.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/assignments/item_container_assignments.json`, `test/fixtures/items/assignable_items.json`, `test/fixtures/containers/assignment_containers.json`
- **Configuration**: Load via `test_config.json` scenario "T04.1"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **3 items** with different availability for assignment testing
  - **2 containers** with different capacity limits
  - **1 existing assignment** to test assignment workflow
- **Key Test Items**:
  - **`assign_item_001`**: "Assignable Bandages" - 100 total, 100 available, 0 assigned
  - **`assign_item_002`**: "Partially Assigned Kit" - 50 total, 20 available, 30 already assigned
  - **`assign_item_003`**: "Heavy Equipment" - 10 total, 5 available, 5 assigned
- **Key Test Containers**:
  - **`assign_container_001`**: "Assignment Container A" - Standard Box, 50kg capacity, 10kg used
  - **`assign_container_002`**: "Assignment Container B" - Large Box, 100kg capacity, empty
- **Assignment Test Scenarios**:
  - **New Assignment**: Assign 25 bandages to Container A
  - **Partial Assignment**: Assign 15 of partially assigned kit to Container B
  - **Capacity Check**: Assign heavy equipment that approaches container weight limit
  - **Multiple Assignments**: Same item to different containers

**Assertions**:
- Item detail page shows "Assign to Container" button for items with available quantity > 0
- Assignment form appears with: container dropdown, quantity input, weight/volume calculation
- Container dropdown shows available containers with capacity info and current utilization
- Assign 25 × assign_item_001 to assign_container_001 → success message "Assignment created successfully"
- After assignment: Item shows 75 available (100-25), Container shows assignment in detail view
- Container capacity updates: Previous 10kg + new assignment weight = updated total
- Item overview shows assignment: "25 assigned to Assignment Container A"
- Assignment appears in both item detail (outbound) and container detail (inbound) views
- Assignment quantity input validation: Cannot assign more than available quantity
- Assignment quantity input validation: Cannot assign zero or negative quantities
- Real-time calculation: As quantity changes, total weight/volume preview updates
- Multiple containers: Same item can be assigned to different containers simultaneously
- Assignment history: Shows timestamp and user who created assignment

#### T04.2: Container-Based Assignment View
**Scenario**: User can manage all assignments for a container
- **Given**: Container has existing assignments
- **When**: User views container assignment page
- **Then**: All assigned items are displayed with quantities
- **And**: User can search and add new items
- **And**: User can modify existing assignments
- **Test File**: `assignment-management.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/assignments/container_based_assignments.json`, `test/fixtures/items/container_assignable_items.json`, `test/fixtures/containers/assignment_view_containers.json`
- **Configuration**: Load via `test_config.json` scenario "T04.2"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **1 container** with multiple existing assignments for management testing
  - **5 items**: 3 already assigned, 2 available for new assignments
- **Key Test Container**:
  - **`container_assign_001`**: "Multi-Assignment Container" - Large Box, 100kg capacity, 45kg currently used
- **Existing Assignments** (container_assign_001):
  - **`assign_001`**: 20 × "Medical Supplies" (15kg total)
  - **`assign_002`**: 10 × "Emergency Kits" (25kg total)
  - **`assign_003`**: 5 × "Water Bottles" (5kg total)
- **Available Items** (for new assignments):
  - **`available_001`**: "First Aid Kits" - 30 available, 2kg per unit
  - **`available_002`**: "Blankets" - 15 available, 1kg per unit
- **Assignment Management Test Scenarios**:
  - **View Existing**: All 3 assignments displayed with correct quantities and weights
  - **Modify Quantity**: Change assign_001 from 20 to 25 units
  - **Add New Item**: Assign 8 × First Aid Kits to container
  - **Remove Assignment**: Delete assign_003 (Water Bottles)
  - **Search Items**: Find "First Aid" in available items list

**Assertions**:
- Container assignment page shows current utilization: "45kg / 100kg (45%)" and "3 items assigned"
- Assignment list displays all 3 existing assignments with item names, quantities, individual weights, total weights
- Each assignment row shows: item name, current quantity, unit weight, total weight, edit/delete buttons
- Assignment totals: 20+10+5 = 35 total items, 15+25+5 = 45kg total weight
- Edit assignment quantity: Change 20 Medical Supplies to 25 → weight updates from 15kg to 18.75kg
- Container capacity updates: New total 48.75kg (was 45kg), percentage updates to 48.75%
- Add new assignment button opens item search/selection dialog
- Item search: Type "First Aid" → shows available_001 "First Aid Kits" with 30 available
- Add 8 × First Aid Kits → assignment list now shows 4 assignments, capacity increases by 16kg
- Remove assignment: Delete Water Bottles assignment → capacity decreases by 5kg, item count decreases by 1
- Capacity validation: Attempt to add items exceeding remaining 51.25kg → error prevents overloading
- Real-time updates: All quantity changes immediately reflect in capacity calculations and totals
- Assignment search: Filter existing assignments by item name to find specific items quickly

#### T04.3: Assignment Quantity Validation
**Scenario**: Assignment quantities are validated correctly
- **Given**: Item has limited available quantity
- **When**: User attempts to assign more than available
- **Then**: System prevents over-assignment with warning
- **And**: Total assignments don't exceed item inventory
- **Test File**: `assignment-validation.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/assignments/quantity_validation_assignments.json`, `test/fixtures/items/validation_items.json`, `test/fixtures/containers/validation_containers.json`
- **Configuration**: Load via `test_config.json` scenario "T04.3"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **3 items** with precise quantity setups for validation testing
  - **3 containers** for assignment distribution testing
  - **2 existing assignments** to test validation boundaries
- **Key Test Items** (quantity validation scenarios):
  - **`validation_item_001`**: "Limited Supplies" - 100 total, 70 available, 30 assigned to Container A
  - **`validation_item_002`**: "Fully Assigned Item" - 50 total, 0 available, 50 assigned to Container B
  - **`validation_item_003`**: "High Demand Item" - 25 total, 5 available, 20 assigned across 2 containers
- **Key Test Containers**:
  - **`validation_container_001`**: "Validation Container A" - has 30 × validation_item_001
  - **`validation_container_002`**: "Validation Container B" - has 50 × validation_item_002
  - **`validation_container_003`**: "Empty Validation Container" - available for new assignments
- **Validation Test Scenarios**:
  - **Over-Assignment**: Try to assign 80 × validation_item_001 (only 70 available)
  - **Zero Available**: Try to assign validation_item_002 (0 available)
  - **Exact Boundary**: Assign exactly 5 × validation_item_003 (exactly available amount)
  - **Negative Quantity**: Try to assign -10 units
  - **Multiple Container Validation**: Assign across multiple containers within total limits

**Assertions**:
- Item validation_item_001 shows "70 available" clearly in assignment interface
- Attempt to assign 80 units → error "Cannot assign 80 units. Only 70 available."
- Assignment quantity input field shows max value hint: "Max: 70"
- Attempt to assign validation_item_002 → "Assign" button disabled, message "No units available for assignment"
- Zero quantity assignment → error "Quantity must be greater than zero"
- Negative quantity input → error "Quantity cannot be negative"
- Assign exactly 5 × validation_item_003 → succeeds, item becomes "0 available" 
- After exact assignment: validation_item_003 no longer appears in "Add Item" dropdown
- Multiple assignment boundary: 30+40=70 validation_item_001 across 2 containers → first succeeds, second fails with "30 units remaining"
- Real-time validation: As user types quantity over limit, error message appears immediately
- Boundary test: Enter 71 units → error appears, reduce to 70 → error disappears, save enabled
- Assignment modification: Increase existing 30 → 35 assignment → error "Would exceed available quantity by 5"
- Cross-container validation: Total assignments across all containers never exceed item total quantity

#### T04.4: Assignment Duplicate Prevention
**Scenario**: System prevents duplicate assignments
- **Given**: Item is already assigned to container
- **When**: User attempts to create duplicate assignment
- **Then**: System either merges quantities or prevents duplicate
- **And**: No duplicate assignment records are created
- **Test File**: `item-quantity.spec.js` (existing covers this)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/assignments/duplicate_prevention_assignments.json`, `test/fixtures/items/duplicate_test_items.json`, `test/fixtures/containers/duplicate_test_containers.json`
- **Configuration**: Load via `test_config.json` scenario "T04.4"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`)
- **Test Data Summary**:
  - **2 items**: 1 with existing assignment, 1 without assignments
  - **2 containers**: 1 with existing assignments, 1 empty
  - **1 existing assignment** to test duplicate prevention
- **Key Test Setup**:
  - **`duplicate_item_001`**: "Test Medical Kit" - 100 total, 75 available, 25 assigned to Container A
  - **`duplicate_item_002`**: "Unassigned Supplies" - 50 total, 50 available, 0 assigned
  - **`duplicate_container_001`**: "Container with Assignment" - has 25 × duplicate_item_001
  - **`duplicate_container_002`**: "Empty Test Container" - no assignments
- **Duplicate Prevention Test Scenarios**:
  - **Exact Duplicate**: Try to assign duplicate_item_001 to duplicate_container_001 again
  - **Quantity Merge**: Add 15 more duplicate_item_001 to existing 25 (should merge to 40)
  - **New Assignment**: Assign duplicate_item_001 to duplicate_container_002 (should work - different container)
  - **Multiple Attempts**: Rapid successive assignment attempts to same item/container pair

**Assertions**:
- Existing assignment shows: 25 × duplicate_item_001 in duplicate_container_001
- Attempt to assign duplicate_item_001 to duplicate_container_001 again → system detects existing assignment
- Duplicate prevention dialog: "Item already assigned to this container. Add to existing assignment?"
- Choose "Add to existing": Enter 15 additional units → existing assignment updates from 25 to 40
- Choose "Cancel": No new assignment created, existing assignment unchanged at 25 units
- Assignment list shows only 1 assignment record for duplicate_item_001 + duplicate_container_001 (no duplicates)
- Assign duplicate_item_001 to duplicate_container_002 → succeeds (different container, allowed)
- Item now shows 2 separate assignments: 25 to Container A, new assignment to Container B
- Database integrity: No duplicate assignment records in underlying data
- Multiple rapid attempts: Click assign button multiple times → only 1 assignment created
- Available quantity calculation: Always based on single assignment record per item/container pair
- Assignment modification: Edit existing assignment quantity directly instead of creating duplicates

### UC05: Deployment Preparation (Packer Workflows)

#### T05.1: Container Verification Workflow
**Scenario**: Packer can verify container contents
- **Given**: Container has assigned items for verification
- **When**: Packer opens container verification view
- **Then**: All assigned items are listed with expected quantities
- **And**: Packer can mark items as verified/missing
- **Test File**: `packer-workflow.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/packer/verification_containers.json`, `test/fixtures/items/verification_items.json`, `test/fixtures/assignments/verification_assignments.json`
- **Configuration**: Load via `test_config.json` scenario "T05.1"
- **Authentication**: User role "Packer" (`packer.test@rescuenet.net`) - has verification permissions
- **Test Data Summary**:
  - **1 container** ready for packer verification with multiple assigned items
  - **4 items** assigned to container with different verification scenarios
- **Key Test Container**:
  - **`verify_container_001`**: "Verification Test Container" - Large Box, ready for packing verification
- **Assigned Items for Verification**:
  - **`verify_item_001`**: "Medical Bandages" - 50 assigned (verify complete)
  - **`verify_item_002`**: "Emergency Kits" - 20 assigned (verify partial - 18 found)
  - **`verify_item_003`**: "Water Bottles" - 100 assigned (verify missing - 0 found)
  - **`verify_item_004`**: "First Aid Supplies" - 25 assigned (verify exact match)
- **Verification Test Scenarios**:
  - **Complete Match**: Found quantity = assigned quantity
  - **Partial Match**: Found quantity < assigned quantity
  - **Missing Items**: Found quantity = 0
  - **Over Found**: Found quantity > assigned quantity (error case)
- **Expected Verification Status**:
  - **Complete**: verify_item_001, verify_item_004 (2 items)
  - **Partial**: verify_item_002 (18/20 found, 2 missing)
  - **Missing**: verify_item_003 (0/100 found, 100 missing)

**Assertions**:
- Verification page shows container details: name, type, destination, total assigned items count (4)
- Verification checklist displays all assigned items with: name, assigned quantity, input field for found quantity
- Each item shows expected quantity prominently: "Expected: 50" for verify_item_001
- Found quantity input field accepts numeric values and validates against reasonable limits
- Mark verify_item_001 as found 50/50 → status changes to "✓ VERIFIED" with green indicator
- Mark verify_item_002 as found 18/20 → status shows "⚠ PARTIAL" with yellow indicator and "2 missing"
- Mark verify_item_003 as found 0/100 → status shows "✗ MISSING" with red indicator and "100 missing"
- Found quantity > assigned quantity → error "Cannot find more than assigned quantity"
- Verification summary: "2 verified, 1 partial, 1 missing" with progress indicator
- Complete verification button enabled only when all items have found quantities entered
- Save verification → container status changes to "Verified" with timestamp and packer name
- Verification report shows discrepancies: "2 items missing" with details for follow-up
- Navigate back to verification → all previously entered quantities preserved
- Bulk actions: "Mark All as Found" button sets all found quantities to assigned quantities

#### T05.2: PDF Generation - Packing Lists
**Scenario**: System generates accurate packing lists
- **Given**: Container has verified assignments
- **When**: User generates packing list PDF
- **Then**: PDF contains all items with correct quantities
- **And**: Dangerous goods are properly flagged
- **And**: Container details are accurate
- **Test File**: `pdf-generation.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/packer/pdf_containers.json`, `test/fixtures/items/pdf_items.json`, `test/fixtures/assignments/pdf_assignments.json`
- **Configuration**: Load via `test_config.json` scenario "T05.2"
- **Authentication**: User role "Packer" (`packer.test@rescuenet.net`) - has PDF generation permissions
- **Test Data Summary**:
  - **2 containers**: 1 verified ready for PDF, 1 with dangerous goods items
  - **6 items**: Mix of regular and dangerous goods items for complete PDF testing
- **Key Test Containers**:
  - **`pdf_container_001`**: "Standard Packing Container" - verified, 4 regular items
  - **`pdf_container_002`**: "Dangerous Goods Container" - verified, 2 dangerous goods items
- **PDF Test Items** (pdf_container_001):
  - **`pdf_item_001`**: "Medical Bandages" - 50 pieces, no dangerous goods
  - **`pdf_item_002`**: "Emergency Blankets" - 25 units, no dangerous goods
  - **`pdf_item_003`**: "First Aid Kits" - 15 kits, no dangerous goods
  - **`pdf_item_004`**: "Water Purification Tablets" - 100 tablets, no dangerous goods
- **Dangerous Goods Test Items** (pdf_container_002):
  - **`pdf_dg_001`**: "Fuel Additive" - 10 bottles, Class 3 (Flammable Liquids)
  - **`pdf_dg_002`**: "Battery Acid" - 5 containers, Class 8 (Corrosive)
- **Expected PDF Content**:
  - **Header**: Container name, destination, generation date, packer name
  - **Item List**: All items with quantities, units, individual/total weights
  - **Dangerous Goods Section**: Separated section with warning symbols
  - **Summary**: Total items count, total weight, dangerous goods summary

**Assertions**:
- PDF generation button visible and enabled for verified containers
- Click "Generate Packing List" → PDF file downloads with filename "packing_list_{container_name}_{date}.pdf"
- PDF contains header with: container name "Standard Packing Container", destination, current date
- PDF shows packer information: "Packed by: packer.test@rescuenet.net" with verification timestamp
- Item list table includes all 4 items with correct data: name, quantity, unit, individual weight, total weight
- PDF item order: Alphabetical by item name for consistent output
- Item quantities match verified amounts: 50 bandages, 25 blankets, 15 kits, 100 tablets
- Total calculations correct: Sum of all item weights = container total weight shown
- Dangerous goods container PDF: Contains warning section "⚠ DANGEROUS GOODS - Handle with Care"
- Dangerous goods items listed separately with: Class 3 symbol for fuel, Class 8 symbol for acid
- DG section includes handling instructions: "Keep away from heat sources" for Class 3
- PDF footer contains: QR code with container ID, page numbers, generation timestamp
- PDF text is readable and properly formatted (no overlapping text or missing data)
- Multiple PDFs: Generate for both containers → each contains only its respective items

#### T05.3: PDF Generation - Labels and Summaries
**Scenario**: System generates container labels and summaries
- **Given**: Container is ready for deployment
- **When**: User generates labels and summary sheets
- **Then**: Labels contain proper identification and QR codes
- **And**: Summary sheets show weight and capacity info
- **Test File**: `pdf-generation.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/packer/label_containers.json`, `test/fixtures/items/label_items.json`, `test/fixtures/reference_data/destinations.json`
- **Configuration**: Load via `test_config.json` scenario "T05.3"
- **Authentication**: User role "Packer" (`packer.test@rescuenet.net`) - has PDF generation permissions
- **Test Data Summary**:
  - **2 containers**: Different sizes and destinations for label variety testing
  - **Complete reference data**: Destinations with addresses and contact information
- **Key Test Containers**:
  - **`label_container_001`**: "Label Test Container A" - Standard Box → Field Office Alpha
  - **`label_container_002`**: "Label Test Container B" - Large Box → Mobile Unit Beta
- **Container Specifications** (for label content):
  - **Container A**: 45kg total weight, 0.4m³ volume, Standard Box (50kg capacity)
  - **Container B**: 78kg total weight, 0.9m³ volume, Large Box (100kg capacity)
- **Expected Label Content**:
  - **QR Code**: Scannable container ID for tracking
  - **Container Info**: Name, type, weight, destination
  - **Route Info**: From location → To destination with addresses
  - **Handling**: Special instructions for dangerous goods (if applicable)
  - **Contact**: Emergency contact information for destination
- **Expected Summary Content**:
  - **Container Overview**: All specifications and utilization
  - **Item Summary**: Count and weight breakdown by category
  - **Deployment Info**: Route, timeline, responsible personnel

**Assertions**:
- Label generation buttons available: "Generate Container Label" and "Generate Summary Sheet"
- Container label PDF downloads with filename "container_label_{container_id}_{date}.pdf"
- Label contains large, readable QR code that encodes container ID for scanning
- Label shows container identification: "Label Test Container A" in prominent text
- Label displays container specifications: "Standard Box - 45kg / 50kg (90%)"
- Label shows route information: "From: Warehouse A → To: Field Office Alpha"
- Label includes destination address and contact phone number from reference data
- Label shows handling instructions: "Handle with Care" and weight warnings if over 30kg
- Summary sheet PDF downloads with filename "container_summary_{container_id}_{date}.pdf"
- Summary contains complete container overview: name, type, current weight, capacity utilization
- Summary shows item breakdown: total items count, weight by category, volume utilization
- Summary includes deployment information: planned route, estimated transit time
- Summary contains emergency contacts: destination contact, logistics coordinator
- Multiple label formats: Standard adhesive size and large shipping label options
- Label text size: Large enough to be readable from 2 meters distance
- QR code functionality: Contains container ID that can be scanned by mobile devices
- Dangerous goods labels: Special DG warning labels generated separately when applicable

#### T05.4: Dangerous Goods Documentation
**Scenario**: System generates proper dangerous goods documentation
- **Given**: Container contains items with dangerous goods
- **When**: User generates deployment documentation
- **Then**: Dangerous goods classifications are included
- **And**: Proper warnings and handling instructions are shown
- **Test File**: `dangerous-goods.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/packer/dangerous_goods_containers.json`, `test/fixtures/items/dangerous_goods_items.json`, `test/fixtures/reference_data/dangerous_goods_classes.json`
- **Configuration**: Load via `test_config.json` scenario "T05.4"
- **Authentication**: User role "Packer" (`packer.test@rescuenet.net`) - has dangerous goods documentation permissions
- **Test Data Summary**:
  - **2 containers**: 1 with multiple DG classes, 1 with single DG class for documentation testing
  - **6 dangerous goods items**: Covering different UN classes with proper classifications
- **Key Test Containers**:
  - **`dg_container_001`**: "Multi-Class DG Container" - contains Class 3, 6, and 8 items
  - **`dg_container_002`**: "Single-Class DG Container" - contains only Class 3 items
- **Dangerous Goods Test Items** (dg_container_001):
  - **`dg_item_001`**: "Fuel Cleaner" - 5 bottles, Class 3 (Flammable Liquids), UN1263
  - **`dg_item_002`**: "First Aid Antiseptic" - 10 bottles, Class 6.1 (Toxic), UN1851
  - **`dg_item_003`**: "Battery Electrolyte" - 3 containers, Class 8 (Corrosive), UN2796
- **Single Class Test Items** (dg_container_002):
  - **`dg_item_004`**: "Alcohol Solvent" - 8 bottles, Class 3 (Flammable Liquids), UN1170
  - **`dg_item_005`**: "Paint Thinner" - 4 containers, Class 3 (Flammable Liquids), UN1263
  - **`dg_item_006`**: "Adhesive" - 12 tubes, Class 3 (Flammable Liquids), UN1133
- **Expected Documentation Content**:
  - **DG Declaration**: Official dangerous goods declaration form
  - **Class Summaries**: Summary of each dangerous goods class present
  - **Handling Instructions**: Specific instructions for each class
  - **Emergency Procedures**: Contact information and response procedures
  - **Segregation Requirements**: Compatibility matrix and separation rules

**Assertions**:
- Dangerous goods documentation button visible only for containers with DG items
- Click "Generate DG Documentation" → PDF downloads with filename "dangerous_goods_{container_id}_{date}.pdf"
- PDF contains official dangerous goods declaration header with container and shipment details
- DG summary table lists all dangerous goods items with: UN number, proper shipping name, class, quantity
- Class 3 items grouped together with warning: "FLAMMABLE LIQUIDS - Keep away from heat, sparks, flames"
- Class 6.1 items show warning: "TOXIC - Avoid inhalation and skin contact"
- Class 8 items show warning: "CORROSIVE - Handle with chemical-resistant gloves"
- Each DG class section includes: diamond-shaped hazard symbol, primary/subsidiary risks
- Emergency procedures section contains: emergency contact numbers, first aid procedures by class
- Handling instructions specific to each item: storage temperature, incompatible materials
- Segregation table shows compatibility between different classes in same container
- PDF includes packer certification: "Packed by: [packer name]" with date and signature line
- Multiple classes container: All classes documented with cross-reference to segregation requirements
- Single class container: Simplified documentation focused on that specific class
- Documentation complies with international dangerous goods regulations (IATA/IMDG format)

### UC06: Post-Deployment Processing

#### T06.1: Post-Deployment Inventory Update
**Scenario**: User can update inventory after deployment
- **Given**: Container was deployed and returned
- **When**: User marks items as used/damaged/lost/returned
- **Then**: Inventory quantities are updated correctly
- **And**: Work log entries are created
- **Test File**: `post-deployment.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/deployment/post_deployment_containers.json`, `test/fixtures/items/deployment_items.json`, `test/fixtures/assignments/deployment_assignments.json`
- **Configuration**: Load via `test_config.json` scenario "T06.1"
- **Authentication**: User role "On Deployment" (`deployment.test@rescuenet.net`) - has post-deployment update permissions
- **Test Data Summary**:
  - **2 containers**: 1 returned from deployment, 1 still deployed for status testing
  - **5 items**: Different post-deployment status scenarios for comprehensive testing
- **Key Test Container**:
  - **`deployed_container_001`**: "Returned Deployment Container" - status "Returned", ready for inventory update
- **Deployment Test Items** (with assigned quantities for status updates):
  - **`deploy_item_001`**: "Medical Supplies" - 50 assigned (update: 30 used, 15 returned, 5 damaged)
  - **`deploy_item_002`**: "Emergency Kits" - 20 assigned (update: 20 used, 0 returned)
  - **`deploy_item_003`**: "Water Bottles" - 100 assigned (update: 80 used, 20 returned)
  - **`deploy_item_004`**: "Blankets" - 25 assigned (update: 20 used, 3 returned, 2 lost)
  - **`deploy_item_005`**: "First Aid Kits" - 15 assigned (update: 10 used, 5 returned)
- **Expected Inventory Impact**:
  - **Total Used**: 30+20+80+20+10 = 160 items marked as used
  - **Total Returned**: 15+0+20+3+5 = 43 items returned to inventory
  - **Total Lost/Damaged**: 5+0+0+2+0 = 7 items lost from inventory
- **Post-Deployment Status Options**:
  - **Used**: Consumed during deployment (reduces total inventory)
  - **Returned**: Brought back unused (returns to available inventory)
  - **Damaged**: Unusable but recovered (removes from inventory)
  - **Lost**: Missing and unrecoverable (removes from inventory)

**Assertions**:
- Post-deployment update page shows container with status "Returned" and all assigned items
- Each item displays: name, assigned quantity, input fields for used/returned/damaged/lost quantities
- Quantity validation: used + returned + damaged + lost = assigned quantity (50 for deploy_item_001)
- Update deploy_item_001: 30 used + 15 returned + 5 damaged = 50 total → quantities balance correctly
- Save updates → success message "Post-deployment inventory updated successfully"
- Item inventory updates: deploy_item_001 total quantity decreases by 35 (30 used + 5 damaged)
- Item inventory updates: deploy_item_001 available quantity increases by 15 (returned items)
- Work log entries created: 5 entries for each item with timestamp, user, and status changes
- Work log details: "30 × Medical Supplies marked as used during deployment to [destination]"
- Cannot update container still deployed: Error "Container must be returned before inventory update"
- Validation error: Total quantities exceed assigned → "Total quantities cannot exceed assigned amount"
- Validation error: Negative quantities → "Quantities must be non-negative"
- Bulk update option: "Mark All as Used" button sets all items to used status quickly
- Summary report: Shows total impact "160 items used, 43 returned, 7 lost/damaged" across all items

#### T06.2: Container Status Management
**Scenario**: Container status updates through deployment cycle
- **Given**: Container goes through deployment process
- **When**: Status changes from packed → deployed → returned
- **Then**: Status is tracked correctly at each stage
- **And**: Historical status is maintained
- **Test File**: `container-lifecycle.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/deployment/lifecycle_containers.json`, `test/fixtures/items/lifecycle_items.json`, `test/fixtures/work_logs/status_history.json`
- **Configuration**: Load via `test_config.json` scenario "T06.2"
- **Authentication**: Multiple roles for status transitions - "Packer", "Logistics", "On Deployment"
- **Test Data Summary**:
  - **3 containers**: Each at different stage of deployment lifecycle
  - **Work log entries**: Historical status changes for audit trail testing
- **Key Test Containers** (lifecycle stages):
  - **`lifecycle_container_001`**: "New Container" - status "Draft" (ready for packing)
  - **`lifecycle_container_002`**: "Packed Container" - status "Packed" (ready for deployment)
  - **`lifecycle_container_003`**: "Deployed Container" - status "Deployed" (in field)
- **Container Lifecycle States**:
  - **Draft**: Newly created, items can be assigned
  - **Packed**: Verified and ready for deployment
  - **Deployed**: Sent to destination, in use
  - **Returned**: Back from deployment, ready for inventory update
  - **Archived**: Post-deployment processing complete
- **Status Transition Rules**:
  - **Draft → Packed**: Requires verification by Packer role
  - **Packed → Deployed**: Requires deployment initiation by Logistics role
  - **Deployed → Returned**: Requires return confirmation by On Deployment role
  - **Returned → Archived**: Requires inventory update completion
- **Expected Status History**:
  - **Timeline tracking**: Each status change with timestamp and responsible user
  - **Audit trail**: Complete history maintained for compliance

**Assertions**:
- Container overview shows status badges: "DRAFT" (gray), "PACKED" (blue), "DEPLOYED" (orange)
- Status transition buttons visible based on current status and user role
- Draft container shows "Mark as Packed" button for Packer role users
- Packed container shows "Deploy Container" button for Logistics role users
- Deployed container shows "Mark as Returned" button for On Deployment role users
- Status transition: lifecycle_container_001 Draft → Packed → status badge updates to "PACKED"
- Work log entry created: "Container status changed from Draft to Packed by packer.test@rescuenet.net"
- Status history page shows complete timeline: creation date, packing date, deployment date
- Cannot skip status stages: Draft container cannot be marked as Deployed directly
- Role-based restrictions: Packer cannot deploy container, Deployment user cannot pack container
- Status timestamps: Each transition recorded with accurate date and time
- Historical data preserved: All previous status changes remain visible in audit log
- Container filtering by status: "Show Deployed" filter displays only containers with status "Deployed"
- Status dashboard: Summary counts "5 Packed, 3 Deployed, 2 Returned" containers
- Notification system: Status changes trigger notifications to relevant users
- Bulk status updates: Select multiple containers → change status in batch operation

### UC07: Reference Data Management

#### T07.1: Container Types Management with Usage Validation
**Scenario**: Container types can be managed with proper validation
- **Given**: Container types may be in use by containers
- **When**: User attempts to delete container type
- **Then**: System prevents deletion if in use
- **And**: Provides clear feedback about usage
- **Test File**: `reference-data.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/reference_data/container_types_usage.json`, `test/fixtures/containers/reference_usage_containers.json`
- **Configuration**: Load via `test_config.json` scenario "T07.1"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has reference data management permissions
- **Test Data Summary**:
  - **4 container types**: 2 in use, 1 unused, 1 new for creation testing
  - **3 containers**: Using specific container types to test deletion protection
- **Key Test Container Types**:
  - **`type_used_001`**: "Standard Box" - 50kg/0.5m³, used by 2 containers (cannot delete)
  - **`type_used_002`**: "Large Box" - 100kg/1.0m³, used by 1 container (cannot delete)  
  - **`type_unused_001`**: "Small Crate" - 25kg/0.25m³, not used (can delete)
  - **`type_create_001`**: For new type creation testing
- **Usage Validation Containers**:
  - **`usage_container_001`**: Uses type_used_001 "Standard Box"
  - **`usage_container_002`**: Uses type_used_001 "Standard Box"
  - **`usage_container_003`**: Uses type_used_002 "Large Box"
- **Container Type Management Scenarios**:
  - **Delete Protection**: Try to delete type_used_001 (used by 2 containers)
  - **Safe Deletion**: Delete type_unused_001 (not used by any containers)
  - **Create New**: Add "Custom Pallet" with 500kg/2.5m³ specifications
  - **Edit Existing**: Modify type_unused_001 capacity before deletion
- **Expected Usage Counts**:
  - **type_used_001**: "Used by 2 containers" (cannot delete)
  - **type_used_002**: "Used by 1 container" (cannot delete)
  - **type_unused_001**: "Not in use" (can delete)

**Assertions**:
- Container types page shows all types with usage indicators: "Used by X containers" or "Not in use"
- Delete button enabled only for unused types (type_unused_001)
- Delete button disabled for used types with tooltip "Cannot delete: in use by containers"
- Attempt to delete type_used_001 → error dialog "Cannot delete 'Standard Box': used by 2 containers"
- Error dialog shows container names: "Currently used by: usage_container_001, usage_container_002"
- Delete type_unused_001 → confirmation dialog "Delete 'Small Crate'? This cannot be undone"
- Confirm deletion → type removed from list and no longer available in container creation dropdown
- Create new type: name="Custom Pallet", max_weight=500, max_volume=2.5, empty_weight=20
- New type validation: Empty weight 600 > max weight 500 → error "Empty weight cannot exceed maximum weight"
- Save new type → appears in list and available for container creation
- Edit existing type: Change type_unused_001 max weight 25→30kg → save → verify updated in list
- Usage tracking updates: Delete container using type → type usage count decreases immediately
- Bulk operations: Select multiple unused types → bulk delete with confirmation
- Reference integrity: Deleted types completely removed from all dropdowns and references

#### T07.2: Location and Destination Management
**Scenario**: Locations and destinations are manageable
- **Given**: User has admin privileges
- **When**: User adds/edits/deletes locations or destinations
- **Then**: Changes persist correctly
- **And**: Usage validation prevents orphaned references
- **Test File**: `reference-data.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/reference_data/locations_destinations.json`, `test/fixtures/items/location_usage_items.json`, `test/fixtures/containers/location_usage_containers.json`
- **Configuration**: Load via `test_config.json` scenario "T07.2"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has reference data admin permissions
- **Test Data Summary**:
  - **5 locations**: 3 in use, 1 unused, 1 for creation testing
  - **4 destinations**: 2 in use, 2 unused for management testing
  - **2 items**: Located at specific locations to test deletion protection
  - **2 containers**: Using specific locations/destinations for usage validation
- **Key Test Locations**:
  - **`location_used_001`**: "Warehouse A" - used by 1 item, 1 container (cannot delete)
  - **`location_used_002`**: "Field Office" - used by 1 item (cannot delete)
  - **`location_used_003`**: "Mobile Unit" - used by 1 container destination (cannot delete)
  - **`location_unused_001`**: "Storage Room C" - not used (can delete)
- **Key Test Destinations**:
  - **`destination_used_001`**: "Emergency Response Base" - used by 1 container (cannot delete)
  - **`destination_used_002`**: "Field Hospital" - used by 1 container (cannot delete)
  - **`destination_unused_001`**: "Unused Outpost" - not used (can delete)
  - **`destination_unused_002`**: "Old Clinic" - not used (can delete)
- **Usage Dependencies**:
  - **Items**: location_item_001 at "Warehouse A", location_item_002 at "Field Office"
  - **Containers**: location_container_001 at "Warehouse A" → "Emergency Response Base"
  - **Container**: location_container_002 at "Field Office" → "Field Hospital"
- **Location Management Scenarios**:
  - **Delete Protection**: Try to delete "Warehouse A" (used by item and container)
  - **Safe Deletion**: Delete "Storage Room C" (not used)
  - **Create New**: Add "Warehouse D" with full contact details
  - **Edit Existing**: Update "Storage Room C" address before deletion

**Assertions**:
- Locations page shows all locations with usage indicators: "Used by X items, Y containers" or "Not in use"
- Each location displays: name, address, contact info, usage count, edit/delete buttons
- Delete button disabled for used locations with tooltip "Cannot delete: referenced by items/containers"
- Attempt to delete "Warehouse A" → error "Cannot delete location: used by 1 item and 1 container"
- Error dialog lists dependencies: "Used by: location_item_001 (item), location_container_001 (container)"
- Delete "Storage Room C" → confirmation "Delete location? This will remove it from all dropdowns"
- Confirm deletion → location removed from item location dropdown and container location dropdown
- Create new location form: name="Warehouse D", address="123 New St", contact="555-0123"
- Location validation: Empty name → error "Location name is required"
- Location validation: Invalid phone format → error "Please enter valid phone number"
- Save new location → appears in all location dropdowns (item location, container current/destination)
- Edit location: Change "Storage Room C" address → save → verify updated in detail view
- Destinations management: Same validation rules apply to destination management
- Delete unused destination → removed from container destination dropdown only
- Usage tracking: Move item from "Warehouse A" → usage count decreases for Warehouse A
- Bulk operations: Select multiple unused locations → bulk delete with usage validation
- Reference integrity: All dropdowns immediately reflect location additions/deletions
- Location hierarchy: Locations can be marked as warehouses vs field locations for filtering

### UC08: Reporting & Analytics

#### T08.1: Work Log Reporting
**Scenario**: System generates comprehensive work logs
- **Given**: Various operations have been performed
- **When**: User generates work log report
- **Then**: All operations are listed chronologically
- **And**: User can filter by date range and operation type  
- **Test File**: `reporting.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/reporting/work_log_entries.json`, `test/fixtures/users/reporting_users.json`
- **Configuration**: Load via `test_config.json` scenario "T08.1"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`) - has reporting permissions
- **Fixed Test Date**: "2024-08-02" for predictable date filtering
- **Test Data Summary**:
  - **15 work log entries** spanning 7 days with different operation types
  - **4 users**: Different roles performing various operations for user filtering
- **Work Log Test Entries** (chronological for filtering):
  - **2024-07-27**: 2 entries (item creation, container creation)
  - **2024-07-30**: 3 entries (assignments, verification)
  - **2024-08-01**: 5 entries (peak activity day - assignments, status changes)
  - **2024-08-02**: 3 entries (current day - post-deployment updates)
  - **2024-08-03**: 2 entries (future entries for range testing)
- **Operation Types Distribution**:
  - **Item Operations**: 4 entries (create, edit, assign, post-deployment)
  - **Container Operations**: 3 entries (create, edit, status change)
  - **Assignment Operations**: 5 entries (create, modify, remove)
  - **System Operations**: 3 entries (user login, report generation)
- **User Activity Distribution**:
  - **backoffice.test@rescuenet.net**: 6 entries (most active)
  - **packer.test@rescuenet.net**: 4 entries (verification activities)
  - **logistics.test@rescuenet.net**: 3 entries (container management)
  - **deployment.test@rescuenet.net**: 2 entries (post-deployment)
- **Expected Filtering Results**:
  - **Date range 2024-08-01 to 2024-08-02**: Should show 8 entries
  - **Operation type "Assignment"**: Should show 5 entries
  - **User "packer.test@rescuenet.net"**: Should show 4 entries

**Assertions**:
- Work log report page shows total entries count: "15 work log entries found"
- Default view displays all entries chronologically (newest first): 2024-08-03 entries at top
- Each entry shows: timestamp, user, operation type, description, affected items/containers
- Date range filter: Select "2024-08-01" to "2024-08-02" → shows exactly 8 entries
- Operation type filter: Select "Assignment Operations" → shows exactly 5 entries  
- User filter: Select "packer.test@rescuenet.net" → shows exactly 4 entries
- Combined filters: Date range + operation type → shows intersection of both filters
- Entry details: Click entry → shows full details including before/after values for changes
- Chronological sorting: Entries within same day ordered by time (latest first)
- Export functionality: "Export to CSV" downloads work log data matching current filters
- Pagination: With 15 entries, shows pagination controls for manageable display
- Search functionality: Search "verification" → shows only entries containing that term
- Activity summary: Shows summary stats "6 item operations, 3 container operations" for filtered results
- Real-time updates: New operations immediately appear in work log without page refresh

#### T08.2: Container Utilization Analytics
**Scenario**: System provides container utilization insights
- **Given**: Containers have varying utilization levels
- **When**: User views utilization analytics
- **Then**: Capacity usage is accurately calculated and displayed
- **And**: Visual indicators help identify optimization opportunities
- **Test File**: `reporting.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/reporting/utilization_containers.json`, `test/fixtures/items/utilization_items.json`, `test/fixtures/assignments/utilization_assignments.json`
- **Configuration**: Load via `test_config.json` scenario "T08.2"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has analytics permissions
- **Test Data Summary**:
  - **6 containers** with precise utilization levels for analytics testing
  - **8 items** assigned to containers for capacity calculations
- **Container Utilization Test Data**:
  - **`analytics_container_001`**: "Empty Container" - 0% utilization (0kg/50kg)
  - **`analytics_container_002`**: "Light Load" - 25% utilization (12.5kg/50kg)
  - **`analytics_container_003`**: "Half Full" - 50% utilization (50kg/100kg)
  - **`analytics_container_004`**: "Heavy Load" - 75% utilization (75kg/100kg)
  - **`analytics_container_005`**: "Near Full" - 90% utilization (45kg/50kg)
  - **`analytics_container_006`**: "Over Capacity" - 110% utilization (55kg/50kg)
- **Analytics Calculation Scenarios**:
  - **Weight Utilization**: Based on assigned item weights vs container capacity
  - **Volume Utilization**: Based on assigned item volumes vs container volume capacity
  - **Item Count**: Number of different items vs optimal loading patterns
  - **Efficiency Metrics**: Space optimization and capacity planning insights
- **Expected Analytics Results**:
  - **Average Utilization**: (0+25+50+75+90+110)/6 = 58.33%
  - **Utilization Distribution**: 1 empty, 1 light, 1 medium, 2 heavy, 1 over-capacity
  - **Optimization Opportunities**: 2 containers under 50%, 1 over capacity
  - **Capacity Totals**: 400kg total capacity, 237.5kg used = 59.4% system utilization
- **Visual Analytics Components**:
  - **Utilization Chart**: Bar/pie chart showing distribution by utilization ranges
  - **Capacity Trend**: Historical utilization over time
  - **Optimization Alerts**: Containers needing attention (empty/over-capacity)
  - **Efficiency Metrics**: KPIs for warehouse management

**Assertions**:
- Analytics dashboard shows summary: "6 containers analyzed, 58.3% average utilization"
- Utilization distribution chart shows correct counts: "1 empty, 1 light load, 1 medium, 2 heavy, 1 over-capacity"
- Container list sorted by utilization: Over Capacity (110%) at top, Empty (0%) at bottom
- Weight utilization calculation: analytics_container_003 shows "50kg / 100kg (50%)"
- Volume utilization: Displays both weight and volume percentages where both are relevant
- Color coding: Green (0-60%), Yellow (61-85%), Orange (86-100%), Red (>100%)
- Optimization alerts: "1 container over capacity" with link to analytics_container_006
- Optimization suggestions: "2 containers under 50% utilization - consider consolidation"
- Capacity trend chart: Shows utilization changes over past 30 days
- Drill-down capability: Click container → detailed capacity breakdown by item
- Export analytics: "Download Report" generates PDF with charts and recommendations
- Filter by container type: "Standard Box" filter shows only 50kg capacity containers
- Filter by utilization range: "Over 75%" shows analytics_container_004, _005, _006
- System-wide metrics: "Total capacity: 400kg, Used: 237.5kg, Available: 162.5kg"
- Efficiency scoring: Each container rated A-F based on utilization efficiency

### UC09: Data Import/Export

#### T09.1: CSV Import with Diff Preview
**Scenario**: CSV import shows changes before applying
- **Given**: User has CSV file with item updates
- **When**: User uploads CSV file
- **Then**: System shows diff of proposed changes
- **And**: User can review and selectively apply changes
- **Test File**: `csv-import.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/import_export/import_existing_items.json`, `test/fixtures/csv_files/import_test_files/`
- **Configuration**: Load via `test_config.json` scenario "T09.1"
- **Authentication**: User role "Logistics" (`logistics.test@rescuenet.net`) - has import permissions
- **Test Data Summary**:
  - **3 existing items** in database for update testing
  - **2 CSV files**: valid and invalid for comprehensive import testing
- **Existing Items for Import Testing**:
  - **`import_existing_001`**: "Medical Bandages" - Warehouse A, 100 pieces, 2025-06-30 expiry
  - **`import_existing_002`**: "Emergency Kits" - Field Office, 50 kits, no expiry
  - **`import_existing_003`**: "Water Bottles" - Mobile Unit, 200 bottles, 2024-12-31 expiry
- **CSV Test Files**:
  - **`valid_import_diff.csv`**: 5 rows (2 updates + 3 new items)
    - **Update**: Medical Bandages quantity 100→150, expiry 2025-06-30→2025-12-31
    - **Update**: Emergency Kits location Field Office→Warehouse A, add expiry 2025-03-15
    - **New**: "Antiseptic Wipes" (Class 3), "Gauze Pads", "Thermometers"
  - **`invalid_import_diff.csv`**: 4 rows (mixed valid/invalid)
    - **Row 1**: Missing required name field
    - **Row 2**: Invalid quantity (-25)
    - **Row 3**: Invalid location "Unknown Warehouse"
    - **Row 4**: Valid new item "Test Supplies"
- **Expected Diff Preview Results**:
  - **Valid CSV**: "2 items to update, 3 new items to create"
  - **Invalid CSV**: "3 validation errors, 1 valid item"
- **Diff Preview Display Format**:
  - **Updates**: Old value → New value highlighting
  - **New Items**: Clearly marked as "NEW" with all field values
  - **Errors**: Red highlighting with specific error messages

**Assertions**:
- CSV import page shows file upload area with drag-and-drop functionality
- File validation: .csv files accepted, other formats rejected with error "Only CSV files are supported"
- Upload valid_import_diff.csv → preview table shows 5 rows with change indicators
- Preview header shows summary: "2 items to update, 3 new items to create"
- Update preview for Medical Bandages: Quantity "100 → 150" highlighted, Expiry "2025-06-30 → 2025-12-31"
- New item preview: Antiseptic Wipes marked with "NEW" badge and all field values shown
- Each row has checkbox: User can uncheck rows to exclude from import
- Upload invalid_import_diff.csv → validation errors highlighted in red
- Error details: Row 1 "Name is required", Row 2 "Quantity must be positive", Row 3 "Invalid location"
- Valid rows in invalid file: Row 4 can still be imported despite other errors
- Selective import: Uncheck Medical Bandages update → summary updates to "1 item to update, 3 new items"
- Confirm import with all valid rows → success message "4 items imported successfully, 1 item updated"
- After import: Navigate to items list → verify Medical Bandages quantity now 150
- After import: Verify new items appear in list with correct data from CSV
- Import history: Shows previous imports with timestamps and row counts

#### T09.2: Data Export with Filtering
**Scenario**: Export respects current view filters
- **Given**: User has applied filters to item/container view
- **When**: User exports data
- **Then**: Export contains only filtered items
- **And**: Export format matches user selection
- **Test File**: `data-export.spec.js` (new)

**Prerequisites**:
- **Test Fixtures**: `test/fixtures/import_export/export_test_data.json`, `test/fixtures/csv_files/export_expected/`
- **Configuration**: Load via `test_config.json` scenario "T09.2"
- **Authentication**: User role "Back Office" (`backoffice.test@rescuenet.net`) - has export permissions
- **Test Data Summary**:
  - **8 items**: Diverse attributes for comprehensive filter testing
  - **4 containers**: Different types and utilization for container export
- **Export Test Items** (for filtering scenarios):
  - **`export_filter_001`**: "Alpha Bandages" - Warehouse A, 100 pieces, Class 3, 2025-03-15 expiry
  - **`export_filter_002`**: "Beta Supplies" - Field Office, 75 kits, None, 2024-12-31 expiry
  - **`export_filter_003`**: "Gamma Equipment" - Warehouse A, 50 units, Class 8, no expiry
  - **`export_filter_004`**: "Delta Materials" - Mobile Unit, 200 pieces, Class 3, 2025-06-30 expiry
  - **`export_filter_005`**: "Epsilon Tools" - Warehouse A, 25 tools, None, 2026-01-10 expiry
  - **`export_filter_006`**: "Zeta Chemicals" - Field Office, 10 bottles, Class 6, 2024-10-15 expiry
  - **`export_filter_007`**: "Eta Devices" - Mobile Unit, 5 devices, None, no expiry
  - **`export_filter_008`**: "Theta Consumables" - Warehouse A, 300 items, Class 9, 2025-12-25 expiry
- **Filter Test Scenarios**:
  - **Location Filter**: "Warehouse A" → should export 4 items (001, 003, 005, 008)
  - **Dangerous Goods Filter**: "Class 3" → should export 2 items (001, 004)
  - **Expiry Date Filter**: "Expires before 2025-01-01" → should export 2 items (002, 006)
  - **Combined Filters**: "Warehouse A" + "Class 3" → should export 1 item (001)
  - **Name Sort**: Alphabetical A-Z → "Alpha" first, "Zeta" last
- **Export Format Options**:
  - **CSV**: Comma-separated values with proper headers
  - **PDF**: Formatted report with tables and summaries
  - **Excel**: .xlsx format with multiple worksheets
- **Expected Export Content**:
  - **Headers**: Name, Description, Location, Quantity, Unit, Expiry Date, Dangerous Goods
  - **Filter Respect**: Only items matching applied filters included
  - **Sort Order**: Export maintains UI sort order

**Assertions**:
- Export dropdown shows format options: CSV, PDF, Excel
- No filters applied: Export all items → CSV contains all 8 test items in correct order
- Apply location filter "Warehouse A" → items list shows 4 items → export CSV contains exactly 4 items
- Exported CSV matches filter: Contains export_filter_001, 003, 005, 008 only
- CSV headers correct: "Name,Description,Location,Total Quantity,Available Quantity,Unit,Expiry Date,Dangerous Goods"
- CSV data format: First row contains correct values for export_filter_001 (Alpha Bandages data)
- Apply dangerous goods filter "Class 3" → export shows only items with Class 3 classification
- Combined filters: Location "Warehouse A" + DG "Class 3" → export contains only export_filter_001
- Sort by name A-Z → export: "Alpha Bandages" appears before "Theta Consumables"
- Sort by expiry date → export: Items with earlier expiry dates appear first
- PDF export: Downloads file with .pdf extension and readable formatted tables
- PDF contains filter summary: "Export filtered by: Location=Warehouse A, Dangerous Goods=Class 3"
- Excel export: Downloads .xlsx file with proper column formatting and data types
- Export filename includes timestamp: "items_export_2024-08-02_14-30-25.csv"
- Large dataset export: Apply no filters with 100+ items → export completes without timeout
- Export respects permissions: Packer role cannot export (button disabled) vs Back Office can export

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