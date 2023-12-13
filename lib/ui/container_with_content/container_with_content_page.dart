import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/services/container_service.dart';
import 'package:rescuenet_warehouse/services/container_visibility_service.dart';
import 'package:rescuenet_warehouse/ui/container_with_content/container_with_content_column.dart';

import '../container_chooser_action.dart';
import '../../models/item.dart';
import '../../models/rescue_container.dart';
import '../rescue_navigation_drawer.dart';
import 'container_with_content_unassigned.dart';

class ContainerWithContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ContainerVisibilityService, ContainerService>(
        builder: (ctxt, visibilityService, service, _) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Container with content"),
            actions: [provideContainerFilterAction(visibilityService, ctxt)],
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
      child: SizedBox(width: 400, child: w));
}