import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'item.dart';
import 'item_card.dart';
import 'menu.dart';
import 'routes.dart';

class ItemOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<ItemService>(
            builder: (ctxt, itemService, _) => Column(children: [
                  Menu(MenuOption.itemOverview),
                  _buttons(context, itemService),
                  Expanded(child: _grid(itemService.items))
                ])));
  }

  _buttons(BuildContext context, ItemService itemService) {
    return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(children: [
          FilledButton(
              onPressed: () {
                var id = itemService.newItem().id;
                Navigator.pushNamed(context, routeItemEditPage, arguments: id);
              },
              child: RescueText.normal("Add item"))
        ]));
  }

  _grid(List<Item> items) => GridView.count(
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
