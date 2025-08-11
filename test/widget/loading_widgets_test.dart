import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';
import 'package:rescuenet_warehouse/widgets/loading/data_loading_indicator.dart';
import 'package:rescuenet_warehouse/widgets/loading/error_retry_widget.dart';
import 'package:rescuenet_warehouse/widgets/loading/operation_loading_overlay.dart';

/// Test file for loading widgets
/// 
/// This file tests all the loading widgets created in Step 1.1, ensuring they
/// handle AsyncValue states correctly and provide proper user feedback.
void main() {
  group('AsyncValueBuilder Tests', () {
    testWidgets('shows loading state correctly', (WidgetTester tester) async {
      const asyncValue = AsyncValue<String>.loading();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueBuilder<String>(
              value: asyncValue,
              data: (data) => Text(data),
            ),
          ),
        ),
      );

      // Should show default loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data'), findsNothing); // Semantic label not visible as text
    });

    testWidgets('shows custom loading widget', (WidgetTester tester) async {
      const asyncValue = AsyncValue<String>.loading();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueBuilder<String>(
              value: asyncValue,
              data: (data) => Text(data),
              loading: () => const Text('Custom Loading'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Loading'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows data state correctly', (WidgetTester tester) async {
      const asyncValue = AsyncValue<String>.data('Hello World');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueBuilder<String>(
              value: asyncValue,
              data: (data) => Text('Data: $data'),
            ),
          ),
        ),
      );

      expect(find.text('Data: Hello World'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error state correctly', (WidgetTester tester) async {
      final asyncValue = AsyncValue<String>.error(
        'Test error',
        StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueBuilder<String>(
              value: asyncValue,
              data: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.text('An error occurred'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows custom error widget', (WidgetTester tester) async {
      final asyncValue = AsyncValue<String>.error(
        'Test error',
        StackTrace.current,
      );
      
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueBuilder<String>(
              value: asyncValue,
              data: (data) => Text(data),
              error: (error, stackTrace) => ErrorRetryWidget(
                error: error,
                onRetry: () => retryPressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      
      // Test retry functionality
      await tester.tap(find.text('Try Again'));
      expect(retryPressed, isTrue);
    });
  });

  group('AsyncValueNullableBuilder Tests', () {
    testWidgets('shows data when not null', (WidgetTester tester) async {
      const asyncValue = AsyncValue<String?>.data('Not null data');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueNullableBuilder<String>(
              value: asyncValue,
              data: (data) => Text('Data: $data'),
            ),
          ),
        ),
      );

      expect(find.text('Data: Not null data'), findsOneWidget);
    });

    testWidgets('shows no data state when data is null', (WidgetTester tester) async {
      const asyncValue = AsyncValue<String?>.data(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueNullableBuilder<String>(
              value: asyncValue,
              data: (data) => Text('Data: $data'),
            ),
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows custom no data widget', (WidgetTester tester) async {
      const asyncValue = AsyncValue<String?>.data(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueNullableBuilder<String>(
              value: asyncValue,
              data: (data) => Text('Data: $data'),
              noData: () => const Text('Custom No Data'),
            ),
          ),
        ),
      );

      expect(find.text('Custom No Data'), findsOneWidget);
    });

    testWidgets('shows loading state correctly', (WidgetTester tester) async {
      const asyncValue = AsyncValue<String?>.loading();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueNullableBuilder<String>(
              value: asyncValue,
              data: (data) => Text('Data: $data'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state correctly', (WidgetTester tester) async {
      final asyncValue = AsyncValue<String?>.error(
        'Nullable error',
        StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueNullableBuilder<String>(
              value: asyncValue,
              data: (data) => Text('Data: $data'),
            ),
          ),
        ),
      );

      expect(find.text('An error occurred'), findsOneWidget);
      expect(find.text('Nullable error'), findsOneWidget);
    });
  });

  group('DataLoadingIndicator Tests', () {
    testWidgets('shows default loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataLoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing); // Message not provided
    });

    testWidgets('shows loading indicator with message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataLoadingIndicator(message: 'Loading items...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading items...'), findsOneWidget);
    });

    testWidgets('shows compact loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataLoadingIndicator.compact(message: 'Loading...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      
      // Verify it uses compact sizing
      final progressIndicator = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(progressIndicator.width, equals(24));
      expect(progressIndicator.height, equals(24));
    });

    testWidgets('shows overlay loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataLoadingIndicator.overlay(message: 'Processing...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing...'), findsOneWidget);
      expect(find.byType(Container), findsWidgets); // Overlay container
    });
  });

  group('DataListLoadingIndicator Tests', () {
    testWidgets('shows placeholder list items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataListLoadingIndicator(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      // Should have 3 placeholder items
      expect(find.byType(Container), findsNWidgets(6)); // 3 items * 2 containers each
    });

    testWidgets('shows card layout when specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataListLoadingIndicator(
              itemCount: 2,
              showAsCards: true,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNWidgets(2));
    });
  });

  group('DataGridLoadingIndicator Tests', () {
    testWidgets('shows placeholder grid items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataGridLoadingIndicator(
              crossAxisCount: 2,
              itemCount: 4,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(4));
    });

    testWidgets('respects cross axis count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataGridLoadingIndicator(
              crossAxisCount: 3,
              itemCount: 6,
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));
    });
  });

  group('ErrorRetryWidget Tests', () {
    testWidgets('shows error message and retry button', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetryWidget(
              error: 'Test error',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('An error occurred: Test error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retryPressed, isTrue);
    });

    testWidgets('shows custom message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorRetryWidget.withMessage(
              message: 'Custom error message',
            ),
          ),
        ),
      );

      expect(find.text('Custom error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows compact layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetryWidget.compact(
              error: 'Compact error',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget); // Compact uses TextButton
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('shows error details when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorRetryWidget(
              error: 'Detailed error',
              showDetails: true,
            ),
          ),
        ),
      );

      expect(find.text('An error occurred: Detailed error'), findsOneWidget); // Main error message
      expect(find.text('Detailed error'), findsOneWidget); // Details section
    });

    testWidgets('handles no retry callback', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorRetryWidget(
              error: 'Error without retry',
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });
  });

  group('ErrorBanner Tests', () {
    testWidgets('shows error banner with message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('shows retry and dismiss buttons', (WidgetTester tester) async {
      bool retryPressed = false;
      bool dismissPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Error with actions',
              onRetry: () => retryPressed = true,
              onDismiss: () => dismissPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.tap(find.byIcon(Icons.close));

      expect(retryPressed, isTrue);
      expect(dismissPressed, isTrue);
    });

    testWidgets('shows custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Custom icon error',
              icon: Icons.info,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsNothing);
    });
  });

  group('OperationLoadingOverlay Tests', () {
    testWidgets('shows operation loading overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperationLoadingOverlay(
              operation: 'Saving item...',
            ),
          ),
        ),
      );

      expect(find.text('Saving item...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('shows operation with details', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperationLoadingOverlay(
              operation: 'Processing data...',
              details: 'This may take a moment',
            ),
          ),
        ),
      );

      expect(find.text('Processing data...'), findsOneWidget);
      expect(find.text('This may take a moment'), findsOneWidget);
    });

    testWidgets('shows progress when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperationLoadingOverlay(
              operation: 'Uploading...',
              progress: 0.5,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.value, equals(0.5));
    });

    testWidgets('can be dismissed when allowed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperationLoadingOverlay(
              operation: 'Dismissible operation',
              canDismiss: true,
            ),
          ),
        ),
      );

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isTrue);
    });

    testWidgets('cannot be dismissed by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperationLoadingOverlay(
              operation: 'Non-dismissible operation',
            ),
          ),
        ),
      );

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });
  });

  group('SimpleLoadingOverlay Tests', () {
    testWidgets('shows simple loading overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleLoadingOverlay(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('shows simple loading overlay with message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleLoadingOverlay(
              message: 'Please wait...',
            ),
          ),
        ),
      );

      expect(find.text('Please wait...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('cannot be dismissed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleLoadingOverlay(),
          ),
        ),
      );

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });
  });
}