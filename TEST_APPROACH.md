# Testing Approach

This document outlines the testing strategy for the RescuenetWarehouse project.

## Testing Philosophy

We follow a pragmatic testing approach optimized for fast-moving startups:

- **KISS**: Keep tests simple and focused
- **SRP**: Each test has a single responsibility
- **Modularity**: Composable helper functions
- **No overtesting**: Focus on critical paths and key error scenarios
- **Pure functions**: Use stateless helpers where possible

## Test Layers

### 1. Integration Tests (Current)

**Location:** `test/integration/`

**Purpose:** Validate CRUD operations and business logic without UI complexity or Firebase dependencies.

**Technology:** Flutter test framework with mock repositories

**Key Characteristics:**
- Tests run in milliseconds (no Firebase latency)
- Use `MockItemRepository`, `MockContainerRepository`, etc.
- Focus on repository-level operations
- Verify stream emissions and state updates
- No widget interaction required

**Current Coverage:**
- ✅ Item CRUD operations (`item_crud_integration_test.dart`)
  - Create with basic and comprehensive fields
  - Update ALL modifiable fields
  - Delete operations
  - Stream emissions
  - Error scenarios

**Planned Coverage:**
- ⏳ Container CRUD operations
- ⏳ Assignment operations (assign/remove items to containers)

### 2. E2E Tests (Existing)

**Location:** `test/puppeteer/`

**Purpose:** Validate full user workflows in the browser with real UI interactions.

**Technology:** Playwright with coordinate-based clicking

**Key Characteristics:**
- Tests the actual deployed Flutter web app
- Uses mock Firebase backend (loaded for Playwright user agent)
- Coordinate-based interaction (Flutter Canvas)
- Screenshots for debugging
- Slower but validates complete integration

**Coverage:**
- Authentication flows
- Container persistence
- Item quantity management
- Container types
- Full workflow integration

## Test Structure

### Helper Organization

```
test/
├── helpers/
│   ├── test_helpers.dart           # Core test utilities (providers, data creation)
│   ├── widget_test_helpers.dart    # Widget testing utilities (NOT USED YET)
│   └── item_field_helpers.dart     # Item field interaction utilities (NOT USED YET)
└── integration/
    ├── item_crud_integration_test.dart
    ├── (future) container_crud_integration_test.dart
    └── (future) assignment_integration_test.dart
```

### Helper Functions

**`test/helpers/test_helpers.dart`** - Core utilities:
- `createTestProviderContainer()` - Creates ProviderContainer with mock repositories
- `createTestItem()` - Creates test Item instances
- `createTestContainer()` - Creates test ContainerDao instances
- `createTestAssignment()` - Creates test Assignment instances
- Mock repository implementations for testing

**`test/helpers/widget_test_helpers.dart`** - Widget testing (prepared for future widget tests):
- `pumpApp()` - Initialize app with MaterialApp wrapper
- `navigateToItemEdit()` - Navigate to item edit page
- `enterText()` - Enter text in fields
- `tapButton()` - Tap buttons
- `waitForLoadingToFinish()` - Wait for loading states

**`test/helpers/item_field_helpers.dart`** - Item field interactions (prepared for future widget tests):
- `fillBasicFields()` - Fill name, description
- `fillAdditionalFields()` - Fill manufacturer, brand, type, etc.
- `setOperationalStatus()` - Set status dropdown
- `setColdChain()` - Set cold chain checkbox
- `verifyItemFields()` - Verify all field values

### Test Pattern

All integration tests follow this structure:

```dart
void main() {
  group('Feature CRUD Integration Tests', () {
    late MockRepository mockRepo;

    setUp(() {
      mockRepo = MockRepository();
      // Clean slate for each test
    });

    tearDown(() {
      mockRepo.dispose();
    });

    group('Create', () {
      test('should create with basic fields', () async {
        // Arrange - Create test data
        // Act - Perform operation
        // Assert - Verify results
      });
    });

    group('Update', () {
      test('should update ALL modifiable fields', () async {
        // Comprehensive field update test
      });
    });

    group('Delete', () {
      test('should delete successfully', () async {
        // Deletion test
      });
    });

    group('Error Scenarios', () {
      test('should handle errors gracefully', () async {
        // 1-2 key error cases
      });
    });

    group('Stream Operations', () {
      test('should emit updates', () async {
        // Verify Riverpod stream behavior
      });
    });
  });
}
```

## What to Test

### ✅ DO Test

1. **CRUD operations** - Create, Read, Update, Delete
2. **All modifiable fields** - In comprehensive update tests
3. **Stream emissions** - Verify Riverpod providers emit updates
4. **Key error scenarios** - Invalid data, not found, etc.
5. **Critical business logic** - Assignment validation, capacity checks
6. **Data persistence** - Verify changes are saved correctly

### ❌ DON'T Test

1. **UI layout details** - Leave for E2E tests
2. **Every edge case** - Focus on critical paths
3. **Framework behavior** - Trust Flutter/Riverpod
4. **External dependencies** - Mock them out
5. **Trivial getters/setters** - Only test meaningful logic

## Running Tests

```bash
# Run all integration tests
flutter test test/integration/

# Run specific test file
flutter test test/integration/item_crud_integration_test.dart

# Run with coverage
flutter test --coverage

# Run E2E tests
cd test/puppeteer && npm test
```

## Writing New Tests

### Step 1: Create Test File

Use the pattern: `{feature}_crud_integration_test.dart`

### Step 2: Add Helpers (if needed)

Add field-specific helpers to `test/helpers/` if testing complex UI interactions.

### Step 3: Follow the Pattern

Copy the structure from `item_crud_integration_test.dart`:
- Setup/teardown with mock repository
- Group by operation type (Create, Update, Delete, etc.)
- Test happy path + 1-2 error scenarios
- Verify stream emissions

### Step 4: Comprehensive Update Test

Always include one test that updates **ALL modifiable fields** to ensure nothing is missed.

### Step 5: Document

Update README.md with new test file and coverage.

## Mock Repositories

**Location:** `lib/repositories/impl/mock/`

**Available Mocks:**
- `MockItemRepository` - Item operations
- `MockContainerRepository` - Container operations
- `MockAssignmentRepository` - Assignment operations
- `MockAuthRepository` - Authentication
- `MockWorkLogRepository` - Work logs
- (others as needed)

**Key Features:**
- Simulate network delays (50ms)
- Emit stream updates
- Throw appropriate exceptions
- Support batch operations
- In-memory storage

## Test Data Creation

Use helper functions from `test/helpers/test_helpers.dart`:

```dart
// Single instances
final item = createTestItem(
  id: 'test-1',
  name: 'Test Item',
  rescueNetId: 1001,
  totalAmount: 10,
);

final container = createTestContainer(
  id: 'container-1',
  name: 'Test Container',
);

// Lists
final items = createTestItems(count: 5);
final containers = createTestContainers(count: 3);
```

## Future Improvements

### Short-term
1. Container CRUD integration tests
2. Assignment integration tests
3. Work log tests

### Medium-term
1. Widget tests for complex UI components
2. Golden tests for visual regression
3. Performance benchmarks

### Long-term
1. Expand E2E test coverage
2. Add accessibility tests
3. Test on multiple form factors

## Resources

- See `TODO_CONTAINER_CRUD_TESTS.md` for container test planning
- See `TODO_ASSIGNMENT_TESTS.md` for assignment test planning
- Existing implementation: `test/integration/item_crud_integration_test.dart`
