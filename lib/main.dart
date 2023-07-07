import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_edit_page.dart';
import 'package:rescuenet_warehouse/container_overview_page.dart';
import 'package:rescuenet_warehouse/container_with_content_page.dart';
import 'package:rescuenet_warehouse/item_edit_page.dart';
import 'package:rescuenet_warehouse/item_edit_page_argument_extractor.dart';
import 'package:rescuenet_warehouse/items_page.dart';
import 'package:rescuenet_warehouse/page/login_register_page.dart';
import 'package:rescuenet_warehouse/page/warehouse_overview_page.dart';
import 'package:rescuenet_warehouse/provider/rn_items_provider.dart';
import 'package:rescuenet_warehouse/provider/sequentialbuild_provider.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/utils/widget_tree_util.dart';
import 'package:rescuenet_warehouse/widget/horizontal_drag_widget.dart';

import 'data_mocks.dart';
import 'edit_custom_values_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

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
          home: ContainerEditPage(container_office),
          routes: {
            // all of the routes in the app
            WareHouseOverviewPage.routeName: (ctx) =>
                const WareHouseOverviewPage(),
            HorizontalDragWidget.routeName: (ctx) =>
                const HorizontalDragWidget(lists: []),
            LoginPage.routeName: (ctx) => const LoginPage(),
            WidgetTree.routeName: (ctx) => const WidgetTree(),

            routeContainerOverview: (ctx) => ContainerOverviewPage([container_office, container_power, container_medical]),
            routeContainerWithContent: (ctx) => ContainerWithContentPage(),
            routeContainerEditPage: (ctx) => ContainerEditPage(container_office),
            routeItemsOverview: (ctx) => ItemsPage(),
            routeEditCustomValues: (ctx) => EditCustomValuesPage(),
            routeItemEditPage: (ctx) => ItemEditPageArgumentExtractor()
          }),
    );
  }
}
