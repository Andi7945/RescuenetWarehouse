# Integration Tests

Integration tests validate repository operations against mock implementations, ensuring business logic works correctly without UI dependencies.

## Running Tests

```bash
# Run all integration tests
flutter test test/integration/

# Run specific test file
flutter test test/integration/assignment_integration_test.dart

# Run with verbose output
flutter test test/integration/ --verbose
```

## Test Files

### `item_crud_integration_test.dart`
- Item CRUD operations (create, read, update, delete)
- Query operations (search, filter)
- Batch operations
- Stream behavior

### `container_crud_integration_test.dart`
- Container CRUD operations
- Query and filter operations
- Batch operations
- Stream behavior

### `assignment_integration_test.dart`
- Assignment CRUD operations (linking items to containers)
- Query operations (by item, by container, by both)
- Batch operations (bulk updates/deletes)
- Business logic (upsertOrDelete with count=0 deletion)
- Stream behavior

## Test Structure

All integration tests follow this pattern:
- Use mock repositories from `lib/repositories/impl/mock/`
- No Firebase or UI dependencies
- Clean state setup in `setUp()`, disposal in `tearDown()`
- Helper functions for test data creation
- Organized by functional groups (CRUD, Query, Batch, Business Logic, Streams)
