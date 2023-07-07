import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_with_content_page.dart';
import 'package:rescuenet_warehouse/data_mocks.dart';
import 'package:rescuenet_warehouse/item_card.dart';
import 'package:rescuenet_warehouse/items_page.dart';
import 'package:rescuenet_warehouse/menu.dart';

import 'container_overview_page.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(),
      // ItemsPage(),
      // ContainerWithContentPage(),
      ContainerOverviewPage([container_office, container_power, container_medical])
    ]));
  }
}
