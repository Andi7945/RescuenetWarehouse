/// Core loading widget foundation for RescuenetWarehouse
library;

///
/// This library provides a complete set of loading widgets that integrate
/// seamlessly with Riverpod's AsyncValue pattern and follow Material Design
/// guidelines, including debounced loading to prevent loading flashes.
///
/// ## Core Components:
///
/// ### AsyncValueBuilder\<T\>
/// Generic widget that handles AsyncValue states from Riverpod providers.
/// Provides consistent loading, error, and data state handling.
///
/// ### DataLoadingIndicator
/// Standard loading spinner for data loading operations with variants for
/// different layout needs (overlay, compact, list, grid).
///
/// ### OperationLoadingOverlay
/// Modal overlay for CRUD operations that prevents user interaction during
/// processing with helper methods for easy integration.
///
/// ### DebouncedLoadingSystem
/// Intelligent loading system that prevents loading flashes for fast operations
/// while maintaining proper feedback for longer operations.
///
/// ### DebouncedLoadingWidgets
/// Collection of widgets that use debounced loading: buttons, overlays, indicators
/// optimized for different operation types (quick, medium, slow, immediate).
///
/// ### ErrorRetryWidget
/// Comprehensive error display with retry functionality, including specialized
/// handling for Firebase errors and network issues.
///
/// ## Usage Examples:
///
/// ```dart
/// // Data loading with AsyncValue
/// AsyncValueBuilder<List<Item>>(
///   value: ref.watch(itemsProvider),
///   data: (items) => ItemGrid(items: items),
///   loading: () => DataLoadingIndicator(),
///   error: (error, stackTrace) => ErrorRetryWidget(
///     error: error,
///     onRetry: () => ref.refresh(itemsProvider),
///   ),
/// )
///
/// // Operation with loading overlay
/// await context.performWithLoading(
///   operation: 'Saving item...',
///   task: () => itemRepository.saveItem(item),
/// );
///
/// // Debounced loading for quick operations (prevents flashing)
/// DebouncedLoadingButton.quick(
///   operationKey: 'update_quantity_${itemId}',
///   onPressed: () => updateQuantity(),
///   child: Text('Update'),
/// );
///
/// // Debounced icon button for assignment changes
/// DebouncedLoadingIconButton.quick(
///   operationKey: 'assignment_${assignmentId}',
///   icon: Icon(Icons.plus_one),
///   onPressed: () => incrementAssignment(),
/// );
///
/// // Simple error handling
/// ErrorRetryWidget.withMessage(
///   message: 'Failed to load data',
///   onRetry: () => ref.refresh(dataProvider),
/// )
/// ```

export 'async_value_builder.dart';
export 'data_loading_indicator.dart';
export 'operation_loading_overlay.dart';
export 'error_retry_widget.dart';
export 'debounced_loading_system.dart';
export 'debounced_loading_widgets.dart';
