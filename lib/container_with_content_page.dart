import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return Scaffold(
        body: Consumer<Store>(
            builder: (ctxt, store, _) => Column(children: [
                  Menu(MenuOption.containerWithContent),
                  TextButton(
                      onPressed: () => showDialog(
                          context: ctxt,
                          builder: (ctx) => ModalContainerChooser(
                                store.containerWithVisible(),
                                key: Key(
                                    "${store.containerWithVisible().hashCode}"),
                              )),
                      child: RescueText.normal("Choose container")),
                  _body(
                      store.itemsWithoutContainer(),
                      store
                          .containerWithVisible()
                          .entries
                          .where((element) => element.value)
                          .map((e) => e.key)
                          .toList(),
                      store.containerWithItems())
                ])));
  }

  Widget _body(
      Map<Item, int> itemsWithoutContainer,
      List<RescueContainer> shown,
      Map<RescueContainer, Map<Item, int>> containers) {
    return Expanded(
        child: ListView(scrollDirection: Axis.horizontal, children: [
      _asBox(ContainerWithContentUnassigned(itemsWithoutContainer)),
      ...shown
          .map(
              (c) => _asBox(ContainerWithContentColumn(c, containers[c] ?? {})))
          .toList()
    ]));
  }

  Widget _asBox(Widget w) => Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: SizedBox(width: 420, child: w));
}
