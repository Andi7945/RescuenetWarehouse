import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/services/item_sort_service.dart';
import 'package:rescuenet_warehouse/ui/item_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_add_button.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_sort_button.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';

import '../../models/item.dart';
import '../item_card.dart';

class ItemOverviewPage extends StatefulWidget {
  @override
  State createState() => _ItemOverviewPageState();
}

class _ItemOverviewPageState extends State<ItemOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemSortService>(
        builder: (ctxt, service, _) => Scaffold(
            appBar: AppBar(
              title: const Text("Item overview"),
              actions: const [
                Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ItemChooserAction()),
                ItemSortButton(),
                ItemAddButton(),
              ],
            ),
            drawer: RescueNavigationDrawer(),
            body: _items(service.items)));
  }

  _items(List<Item> items) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
          child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: items.map((i) => ItemCard(i, i.totalAmount)).toList(),
      )));
}
