import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_base_information.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';
import 'package:rescuenet_warehouse/widgets/loading/data_loading_indicator.dart';
import 'package:rescuenet_warehouse/widgets/loading/error_retry_widget.dart';
import '../helpers/test_helpers.dart';

/// Integration test file for item editing with loading states
/// 
/// This file tests the integration between item editing UI components
/// and the loading infrastructure created in previous steps.
void main() {
  group('Item Editing Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('ItemEditPage shows loading when item is null', (WidgetTester tester) async {
      // Set up container with null current item
      final testContainer = createTestProviderContainer(
        overrides: [
          currentItemNotifierProvider.overrideWith((ref) => null),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: MaterialApp(
            home: Scaffold(
              body: ItemEditPage(),
            ),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      testContainer.dispose();
    });

    testWidgets('ItemEditPage displays item when loaded', (WidgetTester tester) async {
      final testItem = createTestItem();
      
      // Set up container with test item
      final testContainer = createTestProviderContainer(
        overrides: [
          currentItemNotifierProvider.overrideWith((ref) => testItem),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: MaterialApp(
            home: Scaffold(
              body: ItemEditPage(),
            ),
          ),
        ),
      );

      // Should show item editing interface
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(ItemEditPageBaseInformation), findsOneWidget);
      
      testContainer.dispose();
    });

    testWidgets('ItemEditPageBaseInformation shows loading during update', (WidgetTester tester) async {
      final testItem = createTestItem();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ProviderScope(
                overrides: [
                  currentItemNotifierProvider.overrideWith((ref) => testItem),
                ],
                child: ItemEditPageBaseInformation(),
              ),
            ),
          ),
        ),
      );

      // Initially should show normal interface
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Start an item update operation
      final notifier = container.read(dataOperationsNotifierProvider.notifier);
      final updateFuture = notifier.updateItem(testItem.copyWith(name: 'Updated Item'));

      // Trigger a rebuild to show loading state
      await tester.pump();

      // Should show loading indicator during update
      // Note: The specific loading UI depends on the implementation in ItemEditPageBaseInformation
      expect(
        container.read(isOperationLoadingProvider(DataOperation.itemUpdate)),
        isTrue,
      );

      // Wait for update to complete
      await updateFuture;
      await tester.pump();

      // Should no longer be loading
      expect(
        container.read(isOperationLoadingProvider(DataOperation.itemUpdate)),
        isFalse,
      );
    });

    testWidgets('AsyncValueBuilder integration with item data', (WidgetTester tester) async {
      final testItem = createTestItem();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AsyncValueBuilder<Item?>(
                value: AsyncValue.data(testItem),
                data: (item) => item != null 
                  ? Text('Item: ${item.name}')
                  : const Text('No item'),
                loading: () => const DataLoadingIndicator(
                  message: 'Loading item...',
                ),
                error: (error, stackTrace) => ErrorRetryWidget(
                  error: error,
                  onRetry: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item: ${testItem.name}'), findsOneWidget);
    });

    testWidgets('AsyncValueBuilder shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: AsyncValueBuilder<Item?>(
                value: AsyncValue.loading(),
                data: (item) => Text('Item loaded'),
                loading: () => DataLoadingIndicator(
                  message: 'Loading item...',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading item...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AsyncValueBuilder shows error state with retry', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AsyncValueBuilder<Item?>(
                value: AsyncValue.error('Failed to load item', StackTrace.current),
                data: (item) => const Text('Item loaded'),
                error: (error, stackTrace) => ErrorRetryWidget(
                  error: error,
                  onRetry: () => retryPressed = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('An error occurred: Failed to load item'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Try Again'));
      expect(retryPressed, isTrue);
    });

    testWidgets('DataOperationsNotifier integrates with UI loading states', (WidgetTester tester) async {
      final testItem = createTestItem();

      // Custom widget that uses loading state
      Widget loadingAwareWidget() {
        return Consumer(
          builder: (context, ref, child) {
            final isCreating = ref.watch(
              isOperationLoadingProvider(DataOperation.itemCreate),
            );
            final isUpdating = ref.watch(
              isOperationLoadingProvider(DataOperation.itemUpdate),
            );

            if (isCreating) {
              return const DataLoadingIndicator(message: 'Creating item...');
            } else if (isUpdating) {
              return const DataLoadingIndicator(message: 'Updating item...');
            } else {
              return const Text('Ready for operations');
            }
          },
        );
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: loadingAwareWidget(),
            ),
          ),
        ),
      );

      // Initially should show ready state
      expect(find.text('Ready for operations'), findsOneWidget);

      // Start create operation
      final notifier = container.read(dataOperationsNotifierProvider.notifier);
      final createFuture = notifier.createItem(testItem);

      await tester.pump();

      // Should show creating state
      expect(find.text('Creating item...'), findsOneWidget);

      await createFuture;
      await tester.pump();

      // Should return to ready state
      expect(find.text('Ready for operations'), findsOneWidget);

      // Start update operation
      final updateFuture = notifier.updateItem(testItem.copyWith(name: 'Updated'));

      await tester.pump();

      // Should show updating state
      expect(find.text('Updating item...'), findsOneWidget);

      await updateFuture;
      await tester.pump();

      // Should return to ready state
      expect(find.text('Ready for operations'), findsOneWidget);
    });

    testWidgets('Error states are handled correctly in item operations', (WidgetTester tester) async {
      // Use container with error-throwing repository
      final errorContainer = createTestProviderContainer(
        overrides: [
          itemRepositoryProvider.overrideWith((ref) => ThrowingMockItemRepository()),
        ],
      );

      Widget errorAwareWidget() {
        return Consumer(
          builder: (context, ref, child) {
            final hasError = ref.watch(
              hasOperationErrorProvider(DataOperation.itemCreate),
            );
            final error = ref.watch(
              getOperationErrorProvider(DataOperation.itemCreate),
            );

            if (hasError && error != null) {
              return ErrorRetryWidget(
                error: error,
                onRetry: () {
                  ref.read(dataOperationsNotifierProvider.notifier)
                    .clearOperation(DataOperation.itemCreate);
                },
              );
            } else {
              return const Text('No errors');
            }
          },
        );
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: errorContainer,
          child: MaterialApp(
            home: Scaffold(
              body: errorAwareWidget(),
            ),
          ),
        ),
      );

      // Initially no errors
      expect(find.text('No errors'), findsOneWidget);

      // Trigger error by attempting operation
      final notifier = errorContainer.read(dataOperationsNotifierProvider.notifier);
      try {
        await notifier.createItem(createTestItem());
      } catch (e) {
        // Expected error
      }

      await tester.pump();

      // Should show error state
      expect(find.text('Mock repository error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Test retry (which clears error)
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Should return to no error state
      expect(find.text('No errors'), findsOneWidget);

      errorContainer.dispose();
    });

    testWidgets('Multiple concurrent operations show correct loading states', (WidgetTester tester) async {
      Widget multiOperationWidget() {
        return Consumer(
          builder: (context, ref, child) {
            final isCreating = ref.watch(
              isOperationLoadingProvider(DataOperation.itemCreate),
            );
            final isUpdating = ref.watch(
              isOperationLoadingProvider(DataOperation.itemUpdate),
            );
            final isDeleting = ref.watch(
              isOperationLoadingProvider(DataOperation.itemDelete),
            );
            final hasAnyLoading = ref.watch(isAnyOperationLoadingProvider);

            return Column(
              children: [
                if (hasAnyLoading) const Text('Some operation loading'),
                if (isCreating) const Text('Creating item'),
                if (isUpdating) const Text('Updating item'),
                if (isDeleting) const Text('Deleting item'),
                if (!hasAnyLoading) const Text('All operations complete'),
              ],
            );
          },
        );
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: multiOperationWidget(),
            ),
          ),
        ),
      );

      // Initially no operations
      expect(find.text('All operations complete'), findsOneWidget);

      final notifier = container.read(dataOperationsNotifierProvider.notifier);
      
      // Start multiple operations concurrently
      final createFuture = notifier.createItem(createTestItem());
      final updateFuture = notifier.updateItem(createTestItem(id: 'item2'));
      final deleteFuture = notifier.deleteItem('item3');

      await tester.pump();

      // Should show all loading states
      expect(find.text('Some operation loading'), findsOneWidget);
      expect(find.text('Creating item'), findsOneWidget);
      expect(find.text('Updating item'), findsOneWidget);
      expect(find.text('Deleting item'), findsOneWidget);

      // Complete all operations
      await Future.wait([createFuture, updateFuture, deleteFuture]);
      await tester.pump();

      // Should return to complete state
      expect(find.text('All operations complete'), findsOneWidget);
      expect(find.text('Some operation loading'), findsNothing);
    });

    testWidgets('Loading overlays can be shown during operations', (WidgetTester tester) async {
      final testItem = createTestItem();

      // Widget that shows overlay during operations
      Widget overlayTestWidget() {
        return Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(isAnyOperationLoadingProvider);
            
            return Stack(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final notifier = ref.read(dataOperationsNotifierProvider.notifier);
                      await notifier.createItem(testItem);
                    },
                    child: const Text('Create Item'),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: DataLoadingIndicator(
                        message: 'Processing...',
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: overlayTestWidget(),
            ),
          ),
        ),
      );

      // Initially button visible, no overlay
      expect(find.text('Create Item'), findsOneWidget);
      expect(find.text('Processing...'), findsNothing);

      // Tap button to start operation
      await tester.tap(find.text('Create Item'));
      await tester.pump();

      // Should show overlay
      expect(find.text('Processing...'), findsOneWidget);

      // Wait a bit for operation to complete
      await tester.pump(const Duration(milliseconds: 100));
      
      // Operation should complete and overlay disappear
      expect(find.text('Processing...'), findsNothing);
      expect(find.text('Create Item'), findsOneWidget);
    });
  });

  group('Loading Widget Integration Edge Cases', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('AsyncValueBuilder handles rapid state changes', (WidgetTester tester) async {
      final testItem = createTestItem();

      // Provider that can change rapidly
      final stateProvider = StateProvider<AsyncValue<Item?>>((ref) => 
        const AsyncValue.loading());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final asyncValue = ref.watch(stateProvider);
                  return AsyncValueBuilder<Item?>(
                    value: asyncValue,
                    data: (item) => Text('Item: ${item?.name ?? 'null'}'),
                    loading: () => const DataLoadingIndicator(),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Change to data
      container.read(stateProvider.notifier).state = AsyncValue.data(testItem);
      await tester.pump();
      expect(find.text('Item: ${testItem.name}'), findsOneWidget);

      // Change back to loading
      container.read(stateProvider.notifier).state = const AsyncValue.loading();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Change to error
      container.read(stateProvider.notifier).state = AsyncValue.error(
        'Test error',
        StackTrace.current,
      );
      await tester.pump();
      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('Nested AsyncValueBuilders work correctly', (WidgetTester tester) async {
      final testItem = createTestItem();
      final testContainer = createTestContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AsyncValueBuilder<Item>(
                value: AsyncValue.data(testItem),
                data: (item) => AsyncValueBuilder<ContainerDao>(
                  value: AsyncValue.data(testContainer),
                  data: (container) => Text('${item.name} in ${container.name}'),
                  loading: () => const Text('Loading container...'),
                ),
                loading: () => const Text('Loading item...'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('${testItem.name} in ${testContainer.name}'), findsOneWidget);
    });
  });
}