import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/services/container_visibility_service.dart';

import 'container_chooser_modal.dart';

Widget provideContainerFilterAction(
    ContainerVisibilityService visibilityService, BuildContext ctxt) {
  var visible = visibilityService.filteredContainer.entries
      .where((element) => element.value)
      .toList();

  return ActionChip(
      label: Row(children: [
        Text(
            "${visible.length} / ${visibilityService.unfilteredContainerWithVisible().length}"),
        const Icon(Icons.filter_alt, color: Colors.blue)
      ]),
      onPressed: () {
        showDialog(context: ctxt, builder: (ctx) => ContainerChooserModal());
      });
}
