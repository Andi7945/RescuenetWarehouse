# Test Fixtures for RescuenetWarehouse

This directory contains comprehensive test fixtures for all item management test scenarios defined in TEST_SPECIFICATIONS.md.

## Directory Structure

```
test/fixtures/
├── items/                           # Item data for various test scenarios
│   ├── basic_navigation_items.json  # T02.1 - Basic item browsing
│   ├── filtering_sorting_items.json # T02.2 - Filtering and sorting
│   ├── creation_editing_items.json  # T02.3 - CRUD operations
│   ├── quantity_management_items.json # T02.4 - Quantity operations
│   ├── dangerous_goods_items.json   # T02.5 - Dangerous goods testing
│   ├── expiry_tracking_items.json   # T02.6 - Expiry date handling
│   ├── import_export_items.json     # T02.7/T02.8 - Import/export
│   └── containers.json              # Supporting container data
├── users/                           # User authentication and roles
│   ├── test_users.json             # User profiles with roles
│   └── auth_tokens.json            # JWT tokens for authentication
├── reference_data/                  # System reference data
│   ├── locations.json              # Storage locations
│   ├── dangerous_goods.json        # DG classifications
│   ├── container_types.json        # Container type definitions
│   ├── module_destinations.json    # Deployment destinations
│   └── units.json                  # Measurement units
├── csv_files/                      # CSV files for import/export testing
│   ├── valid_import.csv            # Valid CSV for import testing
│   ├── invalid_import.csv          # Invalid CSV for validation testing
│   ├── large_import.csv            # Large dataset for performance testing
│   └── export_expected.csv         # Expected export format
├── test_config.json                # Test configuration and mapping
└── README.md                       # This file
```

## Usage

### Test Configuration
The `test_config.json` file maps each test scenario (T02.1 through T02.8) to its required fixtures and specifies which user role should be used for authentication.

### Loading Fixtures
Each test should load the appropriate fixtures based on the test scenario:

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

### Key Features

1. **Predictable Test Data**: All fixtures use consistent IDs and values for reliable assertions
2. **Comprehensive Coverage**: Data covers all edge cases and scenarios
3. **Role-based Testing**: Different user roles for permission testing
4. **Real-world Data**: Realistic item names, quantities, and attributes
5. **Validation Testing**: Invalid data for testing error handling

### Test Data Characteristics

#### Items
- IDs follow pattern: `{scenario}_{number}` (e.g., `filter_001`, `exp_002`)
- Names are alphabetically ordered for sorting tests
- Quantities vary to test different availability scenarios
- Expiry dates relative to fixed test date (2024-08-02)

#### Users
- Four roles: Packer, Back Office, Logistics, On Deployment
- Each role has specific permissions for authorization testing
- Test emails follow pattern: `{role}.test@rescuenet.net`

#### Reference Data
- Complete dangerous goods classifications (Class 1-9 + None)
- Multiple locations with different capacities
- Various container types and measurement units
- Realistic deployment destinations

### CSV Test Files

#### valid_import.csv
- 3 items: 1 update + 2 new items
- Tests successful import workflow
- Includes items with and without expiry dates

#### invalid_import.csv
- 4 items: 3 invalid + 1 valid
- Tests validation: missing name, negative quantity, invalid location
- Verifies error handling and partial import capability

#### large_import.csv
- 10 items for performance testing
- Tests system behavior with larger datasets
- Mixed data types and classifications

## Maintenance

When adding new test scenarios:
1. Create appropriate fixture files in relevant directories
2. Update `test_config.json` to include new scenario mapping
3. Ensure data follows existing ID and naming conventions
4. Add comprehensive documentation to this README

## Data Validation

All fixture data follows the validation rules defined in `test_config.json`:
- Required fields are present for all entities
- Quantities are within valid ranges (0-999999)
- Text fields respect maximum length constraints
- Dangerous goods classifications are valid
- Dates are in ISO 8601 format