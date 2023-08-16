import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/container_visibility_service.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
import 'package:rescuenet_warehouse/container_with_content_unassigned.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/modal_container_chooser.dart';

import 'filter.dart';
import 'item.dart';
import 'menu.dart';
import 'rescue_container.dart';
import 'rescue_filter_dropdown.dart';
import 'rescue_text.dart';

class ContainerWithContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
        Consumer2<ContainerVisibilityService, ContainerService>(
            builder: (ctxt, visibilityService, service, _) {
      var containers = visibilityService.filteredContainer;
      return Column(children: [
        Menu(MenuOption.containerWithContent),
        _btnRow(ctxt, visibilityService.currentFilter, containers),
        _body(
            service.itemsWithoutContainer(),
            Map.fromEntries(service
                .containerWithItems()
                .entries
                .where((element) => containers[element.key] ?? false)))
      ]);
    }));
  }

  Widget _btnRow(BuildContext ctxt, ValueNotifier<Filter> filterNotifier,
          Map<RescueContainer, bool> containers) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        RescueFilterDropdown(filterNotifier),
        _btnChooseContainer(ctxt, containers)
      ]);

  TextButton _btnChooseContainer(
      BuildContext ctxt, Map<RescueContainer, bool> containers) {
    var visible = containers.entries.where((element) => element.value).toList();
    return TextButton(
        onPressed: () {
          showDialog(context: ctxt, builder: (ctx) => ModalContainerChooser());
        },
        child: RescueText.normal(
            "Choose container (${visible.length} / ${containers.length})"));
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
