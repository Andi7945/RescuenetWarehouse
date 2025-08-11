import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/widgets/loading/debounced_loading_system.dart';
import 'package:rescuenet_warehouse/widgets/loading/debounced_loading_widgets.dart';

void main() {
  group('DebouncedLoadingSystem', () {
    testWidgets('should not show loading immediately for quick operations', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: DebouncedLoadingButton.quick(
                  operationKey: 'test_operation',
                  onPressed: () => Future.delayed(const Duration(milliseconds: 50)),
                  child: const Text('Test Button'),
                ),
              ),
            ),
          ),
        ),
      );

      // Find and tap the button
      final buttonFinder = find.text('Test Button');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump(); // Trigger the operation

      // Should not show loading immediately (within first 50ms)
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Wait 150ms to see if loading appears after debounce delay
      await tester.pump(const Duration(milliseconds: 150));
      
      // By this time, loading should appear if operation is still running
      // But since our operation is only 50ms, it should have completed
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show loading after delay for slow operations', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: DebouncedLoadingButton(
                  operationKey: 'slow_test_operation',
                  config: DebouncedLoadingConfig.quick, // 200ms delay
                  onPressed: () => Future.delayed(const Duration(milliseconds: 400)), // Shorter for test
                  child: const Text('Slow Test Button'),
                ),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Slow Test Button');
      await tester.tap(buttonFinder);
      await tester.pump(); // Start the operation

      // Should not show loading immediately
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Wait for debounce delay (200ms)
      await tester.pump(const Duration(milliseconds: 250));
      
      // Now loading should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for operation to complete and cleanup
      await tester.pumpAndSettle();
      
      // Force complete any pending operations
      final notifier = container.read(quickOperationLoadingProvider('slow_test_operation').notifier);
      notifier.forceComplete();
      
      container.dispose();
    });

    testWidgets('should show loading immediately for immediate config', (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: DebouncedLoadingButton(
                  operationKey: 'immediate_test_operation',
                  config: DebouncedLoadingConfig.immediate,
                  onPressed: () => Future.delayed(const Duration(milliseconds: 100)),
                  child: const Text('Immediate Button'),
                ),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Immediate Button');
      await tester.tap(buttonFinder);
      await tester.pump(); // Start the operation

      // Should show loading immediately
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for completion and cleanup
      await tester.pumpAndSettle();
      
      container.dispose();
    });

    testWidgets('should disable button during operation', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: DebouncedLoadingButton.quick(
                  operationKey: 'disable_test',
                  onPressed: () => Future.delayed(const Duration(milliseconds: 300)),
                  child: const Text('Disable Test'),
                ),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Disable Test');
      
      // Initial state - button should be enabled
      ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      await tester.tap(buttonFinder);
      await tester.pump();

      // During operation - button should be disabled
      button = tester.widget(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // Wait for operation to complete
      await tester.pump(const Duration(milliseconds: 400));

      // After operation - button should be enabled again
      button = tester.widget(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });

  group('DebouncedLoadingNotifier', () {
    test('should track operation state correctly', () {
      final notifier = DebouncedLoadingNotifier(DebouncedLoadingConfig.quick);

      // Initial state
      expect(notifier.state.isOperationActive, false);
      expect(notifier.state.shouldShowLoading, false);

      // Start operation
      notifier.startOperation();
      expect(notifier.state.isOperationActive, true);
      expect(notifier.state.shouldShowLoading, false); // Not yet shown due to debouncing

      // Complete operation
      notifier.completeOperation();
      expect(notifier.state.isOperationActive, false);
      expect(notifier.state.shouldShowLoading, false);
    });

    test('should show loading immediately when debouncing disabled', () {
      final notifier = DebouncedLoadingNotifier(DebouncedLoadingConfig.immediate);

      // Start operation
      notifier.startOperation();
      expect(notifier.state.isOperationActive, true);
      expect(notifier.state.shouldShowLoading, true); // Should show immediately

      notifier.dispose();
    });

    test('should cancel timer when operation completes early', () {
      final notifier = DebouncedLoadingNotifier(DebouncedLoadingConfig.quick);

      notifier.startOperation();
      expect(notifier.state.debounceTimer, isNotNull);

      // Complete before timer fires
      notifier.completeOperation();
      expect(notifier.state.isOperationActive, false);
      expect(notifier.state.shouldShowLoading, false);

      notifier.dispose();
    });
  });

  group('DebouncedLoadingConfig', () {
    test('should have correct preset values', () {
      expect(DebouncedLoadingConfig.quick.minimumDelay, 200);
      expect(DebouncedLoadingConfig.medium.minimumDelay, 100);
      expect(DebouncedLoadingConfig.slow.minimumDelay, 50);
      expect(DebouncedLoadingConfig.immediate.minimumDelay, 0);
      expect(DebouncedLoadingConfig.immediate.disableDebouncing, true);
    });

    test('should support custom configuration', () {
      const config = DebouncedLoadingConfig(
        minimumDelay: 75,
        forceLoadingAfter: 2500,
        disableDebouncing: false,
      );

      expect(config.minimumDelay, 75);
      expect(config.forceLoadingAfter, 2500);
      expect(config.disableDebouncing, false);
    });
  });

  group('DebouncedLoadingIconButton', () {
    testWidgets('should show loading icon during operation', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: DebouncedLoadingIconButton.quick(
                  operationKey: 'icon_test',
                  icon: const Icon(Icons.add),
                  onPressed: () => Future.delayed(const Duration(milliseconds: 500)),
                ),
              ),
            ),
          ),
        ),
      );

      // Initial state - should show the add icon
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap the button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Still no loading initially due to debouncing
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Wait for debounce delay
      await tester.pump(const Duration(milliseconds: 250));

      // Now should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      
      // Wait for operation to complete and cleanup
      await tester.pumpAndSettle();
      
      // Force complete any pending operations
      final notifier = container.read(quickOperationLoadingProvider('icon_test').notifier);
      notifier.forceComplete();
      
      container.dispose();
    });
  });

  group('Integration Tests', () {
    testWidgets('should handle rapid button presses correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: DebouncedLoadingButton.quick(
                  operationKey: 'rapid_test',
                  onPressed: () => Future.delayed(const Duration(milliseconds: 50)),
                  child: const Text('Rapid Test'),
                ),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Rapid Test');

      // Tap rapidly multiple times
      await tester.tap(buttonFinder);
      await tester.pump();
      
      // Second tap should be ignored (button disabled)
      await tester.tap(buttonFinder);
      await tester.pump();

      // Verify button is disabled during first operation
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // Wait for operation to complete
      await tester.pump(const Duration(milliseconds: 100));

      // Button should be enabled again
      final buttonAfter = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttonAfter.onPressed, isNotNull);
    });
  });
}