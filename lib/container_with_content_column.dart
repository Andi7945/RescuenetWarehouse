import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_with_content_header.dart';
import 'package:rescuenet_warehouse/item_card.dart';

import 'models/item.dart';
import 'models/rescue_container.dart';

class ContainerWithContentColumn extends StatelessWidget {
  final RescueContainer _container;
  final Map<Item, int> _items;

  ContainerWithContentColumn(this._container, this._items);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ContainerWithContentHeader(_container, _items),
        ..._items.entries.map((e) => ItemCard(e.key, e.value))
      ],
    );
  }
}
