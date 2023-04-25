import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../page/login_register_page.dart';
import '../provider/rn_items_provider.dart';
import '../provider/sequentialbuild_provider.dart';
import '../widget/horizontal_drag_widget.dart';
import 'auth_util.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);
  static const routeName = "/widget_tree";

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print("snapshot: $snapshot");
          Provider.of<SequentialBuildProvider>(context, listen: false).listenToSequentialBuildModelFromFB();
          Provider.of<RNItemsProvider>(context, listen: false).listenToRNItemsFromFB();
          // .addSequentialBuildModelToFB(SequentialBuildModel(des: "Supplies", sequentialBuildColor: Colors.blue));
          return const HorizontalDragWidget();//WareHouseOverviewPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}