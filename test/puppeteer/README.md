# RescuenetWarehouse Playwright Tests

This test suite validates the bug fixes implemented for the RescuenetWarehouse Flutter application.

## Tests Overview

### 1. Authentication Tests (`authentication.spec.js`)
Tests for the authentication bug fix where new users had to register first (getting "email already used" error) then use forgot password.

**Fixed Issues:**
- New user registration now automatically redirects to main app
- No more need for forgot password workaround
- Proper validation for non-rescuenet.net emails

**Test Cases:**
- ✅ New user registration with rescuenet.net email should auto-redirect
- ✅ Registration with non-rescuenet email should show error
- ✅ Normal login flow should work
- ✅ Forgot password functionality should be accessible

### 2. Container Persistence Tests (`container-persistence.spec.js`)
Tests for the container data persistence bug where container nr1 "Genset 1" lost its container type, module destination and location.

**Fixed Issues:**
- Container type changes now persist to Firebase
- Module destination changes persist properly
- Current location changes persist correctly
- Data survives page refreshes and app reloads

**Test Cases:**
- ✅ Container type changes should persist after save
- ✅ Module destination changes should persist
- ✅ Current location changes should persist
- ✅ Container name changes should persist
- ✅ Page refresh should maintain container data

### 3. Item Quantity Tests (`item-quantity.spec.js`)
Tests for the item quantity bug where tent green dome (ID 42649) had weird amounts, adding and reducing amounts randomly increased by 100+.

**Fixed Issues:**
- Amount input no longer causes random large increases
- Negative amounts prevented
- Extremely large amounts capped at 99,999
- Increment/decrement buttons respect boundaries
- Items can be properly removed from containers

**Test Cases:**
- ✅ Item amounts should not increase randomly
- ✅ Increment/decrement buttons should respect boundaries
- ✅ Negative amounts should be prevented
- ✅ Extremely large amounts should be capped
- ✅ Item removal from container should work properly
- ✅ Assignment quantities should persist correctly
- ✅ Text field weight saving should work with all input methods

### 4. Integration Tests (`integration.spec.js`)
End-to-end tests that validate all fixes working together in realistic user scenarios.

**Test Cases:**
- ✅ Complete workflow: create container, add items, verify persistence
- ✅ Tent green dome scenario: assign, modify, remove
- ✅ Full user journey: register, create container, manage items
- ✅ Data consistency across page refreshes

## Running the Tests

### Prerequisites
1. Flutter app must be running on `http://localhost:8080`
2. Node.js and npm installed
3. Test Firebase account with credentials

### Setup
```bash
cd test/puppeteer
npm install
```

### Run Tests
```bash
# Run all tests
npm test

# Run tests with browser visible
npm run test:headed

# Debug tests step by step
npm run test:debug

# View test report
npm run test:report

# Run a single spec file
npx playwright test authentication.spec.js --project=chromium

# Run a specific test within a spec file
npx playwright test authentication.spec.js --grep "New user registration with rescuenet.net email" --project=chromium

# Run tests with verbose output
npx playwright test --reporter=line

# Run tests and show browser
npx playwright test --headed --project=chromium
```

### Configuration

The tests are configured to:
- Run against `http://localhost:8080` (Flutter web server)
- Test on Chrome, Firefox, Safari, and mobile viewports
- Take screenshots on failure
- Generate HTML reports
- Automatically start Flutter web server before tests

## Test Data Requirements

### User Credentials
Tests expect a test user account:
- Email: `test@rescuenet.net`
- Password: `testpassword`

### Test Environment
- Firebase test database with sample containers and items
- Container types configured
- Module destinations configured
- Current locations configured

## Implementation Notes

### Selectors Strategy
Tests use multiple selector strategies for robustness:
1. Data test IDs (preferred): `[data-testid="container-card"]`
2. Text-based selectors: `text=Container with content`
3. CSS classes: `.container-card`
4. Combination selectors for fallback

### Wait Strategies
- `waitForSelector()` for element presence
- `waitForTimeout()` for animations and auto-save
- `waitForLoadState()` for page navigation

### Error Handling
- Tests include multiple selector fallbacks
- Conditional logic for optional UI elements
- Timeout configurations for slower operations

## Bug Fix Validation

Each test file directly validates the specific bug fixes:

1. **Authentication**: Confirms automatic redirect after registration
2. **Container Persistence**: Verifies Firebase auto-save on field changes
3. **Item Quantity**: Validates input controls and prevents erratic behavior
4. **Integration**: Tests real-world scenarios combining all fixes

## Maintenance

### Adding New Tests
1. Follow existing naming convention: `feature.spec.js`
2. Include descriptive test case names
3. Add appropriate selectors and fallbacks
4. Update this README with new test descriptions

### Updating Selectors
If UI changes break tests:
1. Update data-testid attributes in Flutter code (preferred)
2. Add new selectors to existing fallback chains
3. Update test documentation

### Test Data Management
- Consider using test fixtures for consistent data
- Implement test cleanup for created test data
- Use unique identifiers (timestamps) to avoid conflicts