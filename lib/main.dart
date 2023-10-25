import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_expander_service.dart';
import 'package:rescuenet_warehouse/assignment_service.dart';
import 'package:rescuenet_warehouse/auth_forgot_password_page.dart';
import 'package:rescuenet_warehouse/container_edit_page_argument_extractor.dart';
import 'package:rescuenet_warehouse/container_mapper_service.dart';
import 'package:rescuenet_warehouse/container_overview_page.dart';
import 'package:rescuenet_warehouse/container_visibility_service.dart';
import 'package:rescuenet_warehouse/container_with_content_page.dart';
import 'package:rescuenet_warehouse/edit_custom_values/edit_container_types.dart';
import 'package:rescuenet_warehouse/edit_custom_values/edit_current_locations.dart';
import 'package:rescuenet_warehouse/edit_custom_values/edit_module_destinations.dart';
import 'package:rescuenet_warehouse/edit_custom_values/proxy_container_type_usage.dart';
import 'package:rescuenet_warehouse/stores.dart';
import 'package:rescuenet_warehouse/export_page.dart';
import 'package:rescuenet_warehouse/item_edit_page_argument_extractor.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/page/login_register_page.dart';
import 'package:rescuenet_warehouse/page/warehouse_overview_page.dart';
import 'package:rescuenet_warehouse/provider/rn_items_provider.dart';
import 'package:rescuenet_warehouse/provider/sequentialbuild_provider.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/utils/widget_tree_util.dart';
import 'package:rescuenet_warehouse/widget/horizontal_drag_widget.dart';
import 'package:rescuenet_warehouse/work_log_page.dart';
import 'package:rescuenet_warehouse/work_log_service.dart';
import 'package:uuid/uuid.dart';

import 'container_service.dart';
import 'edit_custom_values/proxy_current_location_usage.dart';
import 'item_overview_page.dart';
import 'proxy_container_options.dart';
import 'edit_custom_values/proxy_module_destination_usage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

var uuid = const Uuid();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => RNItemsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SequentialBuildProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ContainerStore()),
        ChangeNotifierProvider(create: (_) => ItemStore()),
        ChangeNotifierProvider(create: (_) => StoreModuleDestination()),
        ChangeNotifierProvider(create: (_) => StoreCurrentLocations()),
        ChangeNotifierProvider(create: (_) => StoreContainerTypes()),
        ChangeNotifierProvider(create: (_) => WorkLogStore()),
        ChangeNotifierProvider(create: (_) => AssignmentStore()),
        provideMapperService(),
        provideAssignmentExpander(),
        provideItemService(),
        proxyContainerService(),
        provideVisibilityService(),
        proxyModuleDestinationUsage(),
        proxyCurrentLocationUsage(),
        proxyContainerTypeUsage(),
        proxyContainerOptions(),
        provideAssignmentService(),
        provideWorkLogService()
      ],
      child: MaterialApp(
          title: 'RescueNet',
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
            // the colors and font
            primaryColorDark: const Color(0xFF2C3333),
            cardColor: const Color(0xFFF5F2E7),
            fontFamily: 'Quicksand',
          ),
          home: const LoginPage(),
          routes: {
            // all of the routes in the app
            WareHouseOverviewPage.routeName: (ctx) =>
                const WareHouseOverviewPage(),
            HorizontalDragWidget.routeName: (ctx) =>
                const HorizontalDragWidget(lists: []),
            LoginPage.routeName: (ctx) => const LoginPage(),
            WidgetTree.routeName: (ctx) => const WidgetTree(),

            routeForgotPassword: (ctx) => AuthForgotPasswordPage(),

            routeContainerOverview: (ctx) => ContainerOverviewPage(),
            routeContainerWithContent: (ctx) => ContainerWithContentPage(),
            routeContainerEditPage: (ctx) =>
                ContainerEditPageArgumentExtractor(),

            routeItemsOverview: (ctx) => ItemOverviewPage(),
            routeItemEditPage: (ctx) => ItemEditPageArgumentExtractor(),

            routeEditModuleDestinations: (ctx) => EditModuleDestinations(),
            routeEditCurrentLocations: (ctx) => EditCurrentLocations(),
            routeEditContainerTypes: (ctx) => EditContainerTypes(),

            routeWorkLog: (_) => WorkLogPage(),
            routeExport: (_) => ExportPage(),
          }),
    );
  }
}
