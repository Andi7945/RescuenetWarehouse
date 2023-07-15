import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
import 'package:rescuenet_warehouse/container_with_content_unassigned.dart';
import 'package:rescuenet_warehouse/menu_option.dart';

import 'item.dart';
import 'menu.dart';
import 'rescue_container.dart';
import 'store.dart';

class ContainerWithContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.containerWithContent),
      Consumer<Store>(
          builder: (ctxt, store, _) =>
              _body(store.itemsWithoutContainer(), store.containerWithItems()))
    ]));
  }

  Widget _body(Map<Item, int> itemsWithoutContainer,
      Map<RescueContainer, Map<Item, int>> containers) {
    return Expanded(
        child: ListView(scrollDirection: Axis.horizontal, children: [
      _asBox(ContainerWithContentUnassigned(itemsWithoutContainer)),
      ...containers.entries
          .map((e) => _asBox(ContainerWithContentColumn(e.key, e.value)))
          .toList()
    ]));
  }

  Widget _asBox(Widget w) => Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: SizedBox(width: 420, child: w));
}
