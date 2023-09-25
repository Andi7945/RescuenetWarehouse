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
                  Expanded(child: _items(itemService.items))
                ])));
  }

  _buttons(BuildContext context, ItemService itemService) {
    return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(children: [
          FilledButton.tonalIcon(
              onPressed: () {
                var id = itemService.newItem().id;
                Navigator.pushNamed(context, routeItemEditPage, arguments: id);
              },
              icon: const Icon(Icons.add),
              label: RescueText.normal("Add"))
        ]));
  }

  _items(List<Item> items) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: items.map((i) => ItemCard(i, i.totalAmount)).toList(),
      ));
}
