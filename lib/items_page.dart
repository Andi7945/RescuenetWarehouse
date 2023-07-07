import 'package:flutter/material.dart';

import 'data_mocks.dart';
import 'item_card.dart';
import 'menu.dart';

class ItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Menu(), Expanded(child: _grid())]));
  }

  _grid() {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      childAspectRatio: 2,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      children: <Widget>[
        ItemCard(item_fire, item_fire.totalAmount),
        ItemCard(item_chair, item_chair.totalAmount),
        ItemCard(item_desk, item_desk.totalAmount),
        ItemCard(item_generator, item_generator.totalAmount),
        ItemCard(item_cooler, item_cooler.totalAmount),
        ItemCard(item_para, item_para.totalAmount),
        ItemCard(item_splint, item_splint.totalAmount)
      ],
    );
  }
}
