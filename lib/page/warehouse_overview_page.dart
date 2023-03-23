import 'package:flutter/material.dart';

import '../widget/horizontal_drag_widget.dart';


class WareHouseOverviewPage extends StatefulWidget {
  const WareHouseOverviewPage({Key? key}) : super(key: key);
  static const routeName = '/warehouseOverview';

  @override
  State<WareHouseOverviewPage> createState() => _WareHouseOverviewPageState();
}

class _WareHouseOverviewPageState extends State<WareHouseOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
    Column(
      children: [
        Text("Warehouse Overview"),
        HorizontalDragWidget(),
      ],
    ));
  }
}
