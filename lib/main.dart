import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_page.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/container_overview/container_assignments_page.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/search_item_for_assignment/assignment_search_item_page.dart';
import 'package:rescuenet_warehouse/features/item_export/item_export_page.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/state/all_work_logs_notifier.dart';
import 'package:rescuenet_warehouse/state/container_current_filter_notifier.dart';
import 'package:rescuenet_warehouse/state/container_hidden_by_selection_notifier.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:rescuenet_warehouse/state/items_current_filter_notifier.dart';
import 'package:rescuenet_warehouse/state/items_current_sort_notifier.dart';
import 'package:rescuenet_warehouse/state/items_filtered_and_sorted_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/ui/auth_page/auth_forgot_password_page.dart';
import 'package:rescuenet_warehouse/ui/container_edit_page/container_edit_page_argument_extractor.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page.dart';
import 'package:rescuenet_warehouse/ui/container_with_content/container_with_content_page.dart';
import 'package:rescuenet_warehouse/custom_scroll_behavior.dart';
import 'package:rescuenet_warehouse/ui/edit_custom_values/edit_container_types.dart';
import 'package:rescuenet_warehouse/ui/edit_custom_values/edit_current_locations.dart';
import 'package:rescuenet_warehouse/ui/edit_custom_values/edit_module_destinations.dart';
import 'package:rescuenet_warehouse/ui/export_page/export_page.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_argument_extractor.dart';
import 'package:rescuenet_warehouse/ui/auth_page/login_register_page.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/features/item_csv_import/widgets/import_export/item_import_overview.dart';
import 'package:rescuenet_warehouse/ui/work_log_page/work_log_page.dart';
import 'package:uuid/uuid.dart';

import 'repositories/auth_providers.dart';
import 'features/item_delete_multiple/item_delete_multiple_page.dart';
import 'firebase_options.dart';
import 'features/item_overview/item_overview_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Always initialize real Firebase - E2E tests use web-based mocking
  print('Initializing Firebase');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(river.ProviderScope(child: MyApp()));
}

var uuid = const Uuid();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: MaterialApp(
        title: 'RescueNet',
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            },
          ),
          // the colors and font
          primaryColorDark: const Color(0xFF2C3333),
          cardColor: const Color(0xFFF5F2E7),
          fontFamily: 'Quicksand',
          visualDensity: VisualDensity.compact,
        ),
        scrollBehavior: CustomScrollBehavior(),
        home: const _AuthHome(),
        routes: {
          LoginPage.routeName: (ctx) => const LoginPage(),
          routeForgotPassword: (ctx) => AuthForgotPasswordPage(),
          routeContainerOverview: (ctx) => ContainerOverviewPage(),
          routeContainerWithContent: (ctx) => ContainerWithContentPage(),
          routeContainerEditPage: (ctx) => ContainerEditPageArgumentExtractor(),
          routeContainerAssignmentOverviewPage:
              (ctx) => ContainerAssignmentsPage(),
          routeContainerAssignmentSinglePage:
              (ctx) => AssignmentByContainerPage(),
          routeContainerAssignmentSearchItemPage:
              (ctx) => AssignmentSearchItemPage(),
          routeItemsOverview: (ctx) => ItemOverviewPage(),
          routeExportItemsOverview: (_) => ItemExportPage(),
          routeItemEditPage: (ctx) => ItemEditPageArgumentExtractor(),
          routeEditModuleDestinations: (ctx) => EditModuleDestinations(),
          routeEditCurrentLocations: (ctx) => EditCurrentLocations(),
          routeEditContainerTypes: (ctx) => EditContainerTypes(),
          routeWorkLog: (_) => WorkLogPage(),
          routeExport: (_) => ExportPage(),
          routeItemImportOverview: (_) => ItemImportOverviewPage(),
          routeDeleteMultipleItems: (_) => ItemDeleteMultiplePage(),
        },
      ),
    );
  }
}

class _EagerInitialization extends river.ConsumerWidget {
  const _EagerInitialization({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    // Only eagerly initialize providers when user is authenticated
    // This prevents Firebase permission errors on app start
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isAuthenticated) {
      // Eagerly initialize providers by watching them.
      // By using "watch", the provider will stay alive and not be disposed.
      // See https://riverpod.dev/docs/essentials/eager_initialization
      ref.watch(containerTypesAsyncProvider);
      ref.watch(moduleDestinationsAsyncProvider);
      ref.watch(currentLocationsAsyncProvider);
      ref.watch(allContainersAsyncProvider);
      ref.watch(allItemsAsyncProvider);
      ref.watch(allAssignmentsAsyncProvider);
      ref.watch(itemsCurrentFilterNotifierProvider);
      ref.watch(itemsCurrentSortNotifierProvider);
      ref.watch(itemsFilteredAndSortedAsyncProvider);
      ref.watch(containerHiddenBySelectionNotifierProvider);
      ref.watch(containerVisibilityAsyncProvider);
      ref.watch(containerCurrentFilterNotifierProvider);
      ref.watch(allWorkLogsAsyncProvider);
    }

    return child;
  }
}

/// Widget that handles authentication routing.
/// Shows login page when not authenticated, main app when authenticated.
class _AuthHome extends river.ConsumerWidget {
  const _AuthHome();

  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) => user == null
          ? const LoginPage()
          : ContainerWithContentPage(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const LoginPage(),
    );
  }
}
