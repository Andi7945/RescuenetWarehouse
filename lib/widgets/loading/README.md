# Loading Widgets

Core loading widget foundation for RescuenetWarehouse Flutter app that integrates seamlessly with Riverpod's AsyncValue pattern.

## Components

### AsyncValueBuilder\<T\>
Generic widget that handles AsyncValue states from Riverpod providers.

```dart
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

AsyncValueBuilder<List<Item>>(
  value: ref.watch(itemsProvider),
  data: (items) => ItemGrid(items: items),
  loading: () => DataLoadingIndicator(),
  error: (error, stackTrace) => ErrorRetryWidget(
    error: error,
    onRetry: () => ref.refresh(itemsProvider),
  ),
)
```

### DataLoadingIndicator
Standard loading spinner for data loading operations.

```dart
// Basic usage
DataLoadingIndicator()

// With custom message
DataLoadingIndicator(message: 'Loading items...')

// As overlay
DataLoadingIndicator.overlay()

// Compact for cards
DataLoadingIndicator.compact()

// For lists
DataListLoadingIndicator(itemCount: 5)

// For grids
DataGridLoadingIndicator(crossAxisCount: 2)
```

### OperationLoadingOverlay
Modal overlay for CRUD operations that prevents user interaction.

```dart
// Manual usage
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => OperationLoadingOverlay(
    operation: 'Saving item...',
  ),
);

// Using helper method
OperationLoadingOverlay.show(
  context: context,
  operation: 'Deleting items...',
);

// Perform operation with automatic overlay
final result = await context.performWithLoading(
  operation: 'Saving item...',
  task: () => itemRepository.saveItem(item),
);

// Simple overlay
SimpleLoadingOverlay.show(
  context: context,
  message: 'Please wait...',
);
```

### ErrorRetryWidget
Comprehensive error display with retry functionality.

```dart
// Basic error handling
ErrorRetryWidget(
  error: error,
  onRetry: () => ref.refresh(dataProvider),
)

// With custom message
ErrorRetryWidget.withMessage(
  message: 'Failed to load items',
  onRetry: () => ref.refresh(itemsProvider),
)

// For Firebase errors
ErrorRetryWidget.forFirebaseError(
  error: firebaseError,
  onRetry: () => ref.refresh(dataProvider),
)

// Compact version
ErrorRetryWidget.compact(
  error: error,
  onRetry: () => retryOperation(),
)

// Error banner (non-blocking)
ErrorBanner(
  message: 'Failed to sync data',
  onRetry: () => syncData(),
  onDismiss: () => dismissError(),
)
```

## Integration Examples

### With existing item pages
```dart
// In item_overview_page.dart
class ItemOverviewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allItemsNotifierProvider);
    
    return Scaffold(
      body: AsyncValueBuilder<List<Item>>(
        value: itemsAsync,
        data: (items) => ItemGrid(items: items),
        loading: () => DataListLoadingIndicator(itemCount: 6),
        error: (error, _) => ErrorRetryWidget(
          error: error,
          onRetry: () => ref.refresh(allItemsNotifierProvider),
        ),
      ),
    );
  }
}
```

### With CRUD operations
```dart
// In item_edit_page.dart
Future<void> _saveItem() async {
  try {
    await context.performWithLoading(
      operation: 'Saving item...',
      task: () => ref.read(itemRepositoryProvider).saveItem(item),
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item saved successfully')),
      );
    }
  } catch (error) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => ErrorRetryWidget.withMessage(
          message: 'Failed to save item',
          onRetry: () => _saveItem(),
        ),
      );
    }
  }
}
```

## Design Patterns

These widgets follow the established patterns in the RescuenetWarehouse codebase:

- **Riverpod Integration**: Work seamlessly with AsyncValue from providers
- **Material Design**: Use theme colors and components consistently
- **Accessibility**: Include semantic labels and proper contrast
- **Error Handling**: Provide user-friendly error messages with retry options
- **Composability**: Can be combined and customized for specific use cases

## Testing

All widgets are designed to be testable with:
- Widget tests using mock providers
- Integration tests with actual data
- Accessibility testing support