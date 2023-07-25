import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
import 'package:rescuenet_warehouse/container_with_content_unassigned.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/modal_container_chooser.dart';

import 'item.dart';
import 'menu.dart';
import 'rescue_container.dart';
import 'rescue_text.dart';
import 'store.dart';

class ContainerWithContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<Store>(builder: (ctxt, store, _) {
      var containers = store.containerWithVisible();
      var visible =
          containers.entries.where((element) => element.value).toList();
      return Column(children: [
        Menu(MenuOption.containerWithContent),
        TextButton(
            onPressed: () {
              showDialog(
                  context: ctxt,
                  builder: (ctx) => ModalContainerChooser(containers));
            },
            child: RescueText.normal(
                "Choose container (${visible.length} / ${containers.length})")),
        _body(
            store.itemsWithoutContainer(),
            Map.fromEntries(store
                .containerWithItems()
                .entries
                .where((element) => containers[element.key] ?? false)))
      ]);
    }));
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
