import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'models/item.dart';
import 'item_card.dart';

class ContainerWithContentUnassigned extends StatelessWidget {
  final Map<Item, int> _items;

  ContainerWithContentUnassigned(this._items);

  @override
  Widget build(BuildContext context) => ListView(
        shrinkWrap: true,
        children: [
          _header(),
          ..._items.entries.map((e) => ItemCard(e.key, e.value))
        ],
      );

  _header() {
    return Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
        ),
        child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Center(
                child: RescueText.normal("Unassigned", FontWeight.w700))));
  }
}
