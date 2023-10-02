import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/container_visibility_service.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
import 'package:rescuenet_warehouse/container_with_content_unassigned.dart';
import 'package:rescuenet_warehouse/modal_container_chooser.dart';

import 'item.dart';
import 'rescue_container.dart';
import 'widget/rescue_navigation_drawer.dart';

class ContainerWithContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ContainerVisibilityService, ContainerService>(
        builder: (ctxt, visibilityService, service, _) {
      var visible = visibilityService.filteredContainer.entries
          .where((element) => element.value)
          .toList();
      return Scaffold(
          appBar: AppBar(
            title: const Text("Container with content"),
            actions: [
              ActionChip(
                  label: Text(
                      "${visible.length} / ${visibilityService.filteredContainer.length}"),
                  onPressed: () {
                    showDialog(
                        context: ctxt,
                        builder: (ctx) => ModalContainerChooser());
                  }),
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: ctxt,
                        builder: (ctx) => ModalContainerChooser());
                  },
                  icon: const Icon(Icons.filter_alt))
            ],
          ),
          drawer: RescueNavigationDrawer(),
          body: _body(
              service.itemsWithoutContainer(),
              Map.fromEntries(service.containerWithItems().entries.where(
                  (element) =>
                      visibilityService.filteredContainer[element.key] ??
                      false))));
    });
  }

  Widget _body(Map<Item, int> itemsWithoutContainer,
      Map<RescueContainer, Map<Item, int>> containers) {
    return ListView(scrollDirection: Axis.horizontal, children: [
      _asBox(ContainerWithContentUnassigned(itemsWithoutContainer)),
      ..._sort(containers)
          .map((e) => _asBox(ContainerWithContentColumn(e.key, e.value)))
          .toList()
    ]);
  }

  _sort(Map<RescueContainer, Map<Item, int>> containers) {
    var entries = containers.entries.toList();
    entries.sort((a, b) => a.key.number.compareTo(b.key.number));
    return entries;
  }

  Widget _asBox(Widget w) => Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: SizedBox(width: 420, child: w));
}
