import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';

import 'test_helpers.dart';

/// Pumps the app with MaterialApp wrapper and mock providers
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  final container = createTestProviderContainer(overrides: overrides);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: child,
        routes: {
          routeItemEditPage: (ctx) => child,
        },
      ),
    ),
  );
}

/// Navigates to item edit page by item ID
Future<void> navigateToItemEdit(
  WidgetTester tester,
  WidgetRef ref,
  String itemId,
) async {
  final item = createTestItem(id: itemId);
  ref.read(currentItemNotifierProvider.notifier).setItem(item);

  await tester.pumpWidget(
    MaterialApp(
      initialRoute: routeItemEditPage,
      routes: {
        routeItemEditPage: (ctx) => const Scaffold(
          body: Text('Item Edit Page'),
        ),
      },
    ),
  );
  await tester.pumpAndSettle();
}

/// Navigates to create new item page
Future<void> navigateToNewItem(
  WidgetTester tester,
  WidgetRef ref,
) async {
  await ref.read(currentItemNotifierProvider.notifier).addItem();
  await tester.pumpAndSettle();
}

/// Enters text in a field and pumps
Future<void> enterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Taps a button by finder or text
Future<void> tapButton(
  WidgetTester tester,
  dynamic buttonIdentifier,
) async {
  final Finder finder = buttonIdentifier is String
      ? find.text(buttonIdentifier)
      : buttonIdentifier as Finder;

  await tester.tap(finder);
  await tester.pump();
}

/// Waits for CircularProgressIndicator to disappear
Future<void> waitForLoadingToFinish(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(const Duration(milliseconds: 100));

    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      return;
    }
  }

  throw TimeoutException(
    'Loading indicator did not disappear within timeout',
    timeout,
  );
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (${timeout.inSeconds}s)';
}
