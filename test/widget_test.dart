// Main widget test file for RescuenetWarehouse
//
// This file contains smoke tests to ensure the app initializes correctly
// and that the loading infrastructure integrates properly with the main app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('App Initialization Tests', () {
    testWidgets('App initializes without errors', (WidgetTester tester) async {
      // Set up test environment with mock repositories
      final container = createTestProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // The app should initialize without throwing errors
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Clean up
      container.dispose();
    });

    testWidgets('App shows login page initially', (WidgetTester tester) async {
      // Set up test environment with mock repositories
      final container = createTestProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Should show login-related elements (this may vary based on auth state)
      // We're mainly testing that the app doesn't crash during initialization
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      
      // Clean up
      container.dispose();
    });

    testWidgets('App handles provider initialization correctly', (WidgetTester tester) async {
      // Set up test environment with mock repositories
      final container = createTestProviderContainer();

      // Verify container starts with default values
      expect(container.read(isMockModeProvider), isTrue);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // App should initialize with providers working
      await tester.pump();
      
      // No specific assertions needed - just ensuring no crashes
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Clean up
      container.dispose();
    });
  });

  group('Loading Infrastructure Integration', () {
    testWidgets('App can handle loading states', (WidgetTester tester) async {
      // Set up test environment with mock repositories
      final container = createTestProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Verify that loading infrastructure is available
      // (No specific UI to test here, just ensuring initialization works)
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Clean up
      container.dispose();
    });

    testWidgets('App handles theme correctly with loading widgets', (WidgetTester tester) async {
      // Set up test environment with mock repositories
      final container = createTestProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // Wait for initialization
      await tester.pump();

      // Get the MaterialApp to verify theme is set up
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      
      // Clean up
      container.dispose();
    });
  });

  group('Error Handling', () {
    testWidgets('App gracefully handles provider errors', (WidgetTester tester) async {
      // Set up test environment with mock repositories
      final container = createTestProviderContainer();

      // The app should handle provider initialization errors gracefully
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // Should not throw errors during initialization
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Clean up
      container.dispose();
    });
  });
}
