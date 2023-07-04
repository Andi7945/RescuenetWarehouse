import 'package:flutter/material.dart';

import 'data_mocks.dart';
import 'item_card.dart';

class ItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: _grid());
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
        ItemCard(item1, item1.totalAmount),
        ItemCard(item2, item2.totalAmount),
        ItemCard(item3, item3.totalAmount),
        ItemCard(item4, item4.totalAmount),
        ItemCard(item5, item5.totalAmount),
        ItemCard(item6, item6.totalAmount),
        ItemCard(item7, item7.totalAmount)
      ],
    );
  }
}
