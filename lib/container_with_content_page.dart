import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
import 'package:rescuenet_warehouse/data_mocks.dart';
import 'package:rescuenet_warehouse/menu_option.dart';

import 'menu.dart';
import 'rescue_container.dart';
import 'store.dart';

class ContainerWithContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.containerWithContent),
      Consumer<Store>(builder: (ctxt, store, _) => _body(store.containers))
    ]));
  }

  Widget _body(List<RescueContainer> containers) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ContainerWithContentColumn(
          containers[0], {item_fire: 2, item_chair: 13, item_desk: 1}),
      ContainerWithContentColumn(
          containers[1], {item_generator: 1, item_fire: 2}),
      ContainerWithContentColumn(
          containers[2], {item_cooler: 1, item_para: 1000, item_splint: 1})
    ]);
  }
}
