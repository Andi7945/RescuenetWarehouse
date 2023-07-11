import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'item.dart';
import 'item_card.dart';
import 'menu.dart';
import 'store.dart';

class ItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Menu(), Expanded(child: _grid())]));
  }

  _grid() =>
      Consumer<Store>(builder: (ctxt, store, _) => _buildGrid(store.items));

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
