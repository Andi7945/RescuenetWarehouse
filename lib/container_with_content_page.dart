import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
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
          builder: (ctxt, store, _) => _body(store.containerWithItems()))
    ]));
  }

  Widget _body(Map<RescueContainer, Map<Item, int>> containers) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: containers.entries
            .map((e) => ContainerWithContentColumn(e.key, e.value))
            .toList());
  }
}
