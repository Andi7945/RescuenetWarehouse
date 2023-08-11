import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/menu_option.dart';

import 'item.dart';
import 'item_card.dart';
import 'menu.dart';

class ItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.itemOverview),
      Expanded(child: _grid())
    ]));
  }

  _grid() => Consumer<ItemService>(
      builder: (ctxt, itemService, _) => _buildGrid(itemService.items));

  _buildGrid(List<Item> items) => GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        childAspectRatio: 2,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: <Widget>[
          ...items.map((i) => ItemCard(i, i.totalAmount)).toList()
        ],
      );
}
