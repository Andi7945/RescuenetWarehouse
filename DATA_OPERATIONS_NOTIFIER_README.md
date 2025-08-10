# DataOperationsNotifier System

A comprehensive CRUD operation loading state management system for the RescuenetWarehouse application, built with Riverpod and following the established patterns from the AuthNotifier.

## Overview

The DataOperationsNotifier provides centralized loading state management for all CRUD operations across Items, Containers, and Assignments. It uses `AsyncValue<void>` to track operation states and provides consistent error handling following Firebase patterns from the codebase.

## Architecture

### Core Components

1. **DataOperationsNotifier** (`lib/state/data_operations_notifier.dart`)
   - Main notifier class that manages operation states
   - Follows the exact pattern from AuthNotifier with AsyncValue<void>
   - Supports concurrent operations with separate state tracking

2. **DataOperation Enum**
   - Defines all supported CRUD operations
   - Enables operation-specific loading states
   - Supports Items, Containers, and Assignments

3. **DataOperationsState Class**
   - Immutable state container for multiple concurrent operations
   - Provides convenient methods for checking loading states and errors
   - Maintains a map of operation types to their AsyncValue states

4. **Convenience Providers**
   - `isAnyOperationLoadingProvider`: Check if any operation is active
   - `isOperationLoadingProvider`: Check specific operation loading state
   - `getOperationErrorProvider`: Get error for specific operation
   - `hasOperationErrorProvider`: Check if operation has error

### Integration with Loading Widgets

The system integrates seamlessly with the loading widgets created in step 1.1:

- **OperationLoadingOverlay**: Modal overlays for operations
- **DataLoadingIndicator**: Inline loading indicators
- **AsyncValueBuilder**: Generic AsyncValue handling

## Usage Examples

### Basic Operation with State Tracking

```dart
class ItemCreateButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch loading state for item creation
    final isCreating = ref.watch(isOperationLoadingProvider(DataOperation.itemCreate));
    final error = ref.watch(getOperationErrorProvider(DataOperation.itemCreate));

    return Column(
      children: [
        // Show error if exists
        if (error != null)
          ErrorWidget(error: error),
        
        // Button with loading state
        ElevatedButton(
          onPressed: isCreating ? null : () => _createItem(ref),
          child: isCreating
              ? Row(
                  children: [
                    CircularProgressIndicator(),
                    Text('Creating...'),
                  ],
                )
              : Text('Create Item'),
        ),
      ],
    );
  }

  Future<void> _createItem(WidgetRef ref) async {
    final item = Item(/* ... */);
    
    try {
      // Notifier automatically handles loading states
      await ref.read(dataOperationsNotifierProvider.notifier).createItem(item);
      // Success handling
    } catch (error) {
      // Error automatically stored in notifier state
    }
  }
}
```

### Using with Loading Overlays

```dart
Future<void> _createItemWithOverlay(BuildContext context, WidgetRef ref) async {
  try {
    await context.performWithLoading<void>(
      operation: 'Creating new item...',
      details: 'Please wait while we save your item',
      task: () async {
        final newItem = Item(/* ... */);
        await ref.read(dataOperationsNotifierProvider.notifier).createItem(newItem);
      },
    );
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item created successfully!')),
    );
  } catch (error) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed: $error')),
    );
  }
}
```

### Monitoring Multiple Operations

```dart
class OperationsDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operationsState = ref.watch(dataOperationsNotifierProvider);
    final isAnyLoading = ref.watch(isAnyOperationLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Operations'),
        // Visual indicator for active operations
        backgroundColor: isAnyLoading 
            ? Colors.orange.withOpacity(0.8) 
            : null,
        actions: [
          if (isAnyLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status for each operation type
          _buildOperationStatus('Item Creation', DataOperation.itemCreate),
          _buildOperationStatus('Item Update', DataOperation.itemUpdate),
          _buildOperationStatus('Container Creation', DataOperation.containerCreate),
          // ... more operations
        ],
      ),
    );
  }

  Widget _buildOperationStatus(String title, DataOperation operation) {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(isOperationLoadingProvider(operation));
        final hasError = ref.watch(hasOperationErrorProvider(operation));
        
        return ListTile(
          title: Text(title),
          trailing: isLoading
              ? CircularProgressIndicator()
              : hasError
                  ? Icon(Icons.error, color: Colors.red)
                  : Icon(Icons.check, color: Colors.green),
        );
      },
    );
  }
}
```

### Batch Operations

```dart
Future<void> _batchUpdateItems(WidgetRef ref, List<Item> items) async {
  try {
    // Automatically sets DataOperation.itemBatchUpdate to loading
    await ref.read(dataOperationsNotifierProvider.notifier).batchUpdateItems(items);
    
    // Show success message
    print('${items.length} items updated successfully');
  } catch (error) {
    // Error state automatically tracked
    print('Batch update failed: $error');
  }
}
```

## Supported Operations

### Item Operations
- `itemCreate` - Create new items
- `itemUpdate` - Update existing items  
- `itemDelete` - Delete items
- `itemBatchUpdate` - Batch update multiple items

### Container Operations
- `containerCreate` - Create new containers
- `containerUpdate` - Update existing containers
- `containerDelete` - Delete containers
- `containerBatchUpdate` - Batch update multiple containers

### Assignment Operations
- `assignmentCreate` - Create new assignments
- `assignmentUpdate` - Update existing assignments (includes upsert/delete logic)
- `assignmentDelete` - Delete assignments
- `assignmentBatchUpdate` - Batch update multiple assignments
- `assignmentBatchDelete` - Batch delete multiple assignments

## Error Handling

The system provides comprehensive error handling following Firebase patterns:

1. **Automatic Error Capture**: Errors are automatically stored in the operation state
2. **Custom Exception Support**: Handles ItemException, ContainerException, and other custom exceptions
3. **Error Accessibility**: Errors can be accessed via convenience providers
4. **Error Clearing**: Operations can be manually cleared to reset error states

```dart
// Check for specific operation errors
final createError = ref.watch(getOperationErrorProvider(DataOperation.itemCreate));
if (createError != null) {
  // Handle error - show message, retry option, etc.
}

// Clear specific operation state
ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemCreate);

// Clear all operation states
ref.read(dataOperationsNotifierProvider.notifier).clearAll();
```

## Integration with Existing Codebase

### Repository Pattern Compatibility

The notifier works seamlessly with existing repository implementations:

```dart
// Works with both Firebase and Mock repositories
final repository = ref.read(itemRepositoryProvider);
await repository.upsertItem(item); // Called internally by notifier
```

### State Notifier Compatibility

Integrates with existing state notifiers:

```dart
class ItemListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch data from existing notifiers
    final items = ref.watch(allItemsNotifierProvider);
    
    // Watch operation states from DataOperationsNotifier
    final isCreating = ref.watch(isOperationLoadingProvider(DataOperation.itemCreate));
    
    return Scaffold(
      body: ItemGrid(items: items),
      floatingActionButton: FloatingActionButton(
        onPressed: isCreating ? null : () => _createItem(ref),
        child: isCreating 
            ? CircularProgressIndicator() 
            : Icon(Icons.add),
      ),
    );
  }
}
```

## Testing

### Unit Testing the Notifier

```dart
void main() {
  group('DataOperationsNotifier', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Mock repositories for testing
          itemRepositoryProvider.overrideWith((ref) => MockItemRepository()),
        ],
      );
    });

    test('should set loading state during item creation', () async {
      final notifier = container.read(dataOperationsNotifierProvider.notifier);
      
      // Initially not loading
      expect(
        container.read(isOperationLoadingProvider(DataOperation.itemCreate)), 
        false,
      );
      
      // Start operation (this would set loading state)
      final future = notifier.createItem(testItem);
      
      // Should be loading
      expect(
        container.read(isOperationLoadingProvider(DataOperation.itemCreate)), 
        true,
      );
      
      await future;
      
      // Should not be loading after completion
      expect(
        container.read(isOperationLoadingProvider(DataOperation.itemCreate)), 
        false,
      );
    });

    test('should handle errors properly', () async {
      // Configure mock to throw error
      final mockRepository = container.read(itemRepositoryProvider) as MockItemRepository;
      when(() => mockRepository.upsertItem(any())).thenThrow(
        ItemException('Test error'),
      );
      
      final notifier = container.read(dataOperationsNotifierProvider.notifier);
      
      try {
        await notifier.createItem(testItem);
        fail('Should have thrown');
      } catch (error) {
        // Error should be stored in state
        expect(
          container.read(hasOperationErrorProvider(DataOperation.itemCreate)),
          true,
        );
        
        final storedError = container.read(
          getOperationErrorProvider(DataOperation.itemCreate),
        );
        expect(storedError, isA<ItemException>());
      }
    });
  });
}
```

### Integration Testing

```dart
void main() {
  testWidgets('should show loading state during item creation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ItemOperationsExample(),
        ),
      ),
    );

    // Find the create button
    final createButton = find.text('Create Example Item');
    expect(createButton, findsOneWidget);

    // Tap to start creation
    await tester.tap(createButton);
    await tester.pump();

    // Should show loading state
    expect(find.text('Creating...'), findsOneWidget);
    
    // Wait for operation to complete
    await tester.pumpAndSettle();

    // Should show success or back to normal state
    expect(find.text('Create Example Item'), findsOneWidget);
  });
}
```

## Performance Considerations

1. **Selective Watching**: Use specific operation providers rather than watching the entire state
2. **Operation Cleanup**: Clear operations when no longer needed to prevent memory leaks
3. **Error Management**: Clear error states after handling to prevent stale error displays
4. **Concurrent Operations**: The system supports multiple concurrent operations without performance impact

## Best Practices

1. **Clear Operations**: Clear operation states after handling errors or when navigating away
2. **Specific Providers**: Use operation-specific providers for better performance
3. **Error Handling**: Always handle errors appropriately and provide user feedback
4. **Loading States**: Provide visual feedback for all operations, especially long-running ones
5. **Accessibility**: Include semantic labels for loading indicators and error states

## Files Created

- `lib/state/data_operations_notifier.dart` - Main notifier implementation
- `lib/state/data_operations_notifier.g.dart` - Generated Riverpod code
- `lib/examples/data_operations_example.dart` - Comprehensive usage examples
- `DATA_OPERATIONS_NOTIFIER_README.md` - This documentation

## Integration with Existing Loading Widgets

The DataOperationsNotifier works seamlessly with the loading widgets from step 1.1:

- **OperationLoadingOverlay**: Use `context.performWithLoading()` extension
- **AsyncValueBuilder**: Use for handling AsyncValue states
- **DataLoadingIndicator**: Use for inline loading feedback

See the examples in `lib/examples/data_operations_example.dart` for detailed integration patterns.