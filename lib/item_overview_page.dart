import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/widget/rescue_navigation_drawer.dart';

import 'models/item.dart';
import 'item_card.dart';
import 'routes.dart';

class ItemOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemService>(
        builder: (ctxt, itemService, _) => Scaffold(
            appBar: AppBar(
              title: const Text("Item overview"),
              actions: [
                IconButton(
                    onPressed: () async {
                      var id = itemService.newItem().id;
                      Navigator.pushNamed(context, routeItemEditPage,
                          arguments: id);
                    },
                    icon: const Icon(Icons.add))
              ],
            ),
            drawer: RescueNavigationDrawer(),
            body: _items(itemService.items)));
  }

  _items(List<Item> items) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: items.map((i) => ItemCard(i, i.totalAmount)).toList(),
      ));
}
