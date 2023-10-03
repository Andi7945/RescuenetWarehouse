import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_visibility_service.dart';

import 'modal_container_chooser.dart';

Widget provideContainerFilterAction(
    ContainerVisibilityService visibilityService, BuildContext ctxt) {
  var visible = visibilityService.filteredContainer.entries
      .where((element) => element.value)
      .toList();

  return ActionChip(
      label: Row(children: [
        Text(
            "${visible.length} / ${visibilityService.containerWithVisible().length}"),
        const Icon(Icons.filter_alt, color: Colors.blue)
      ]),
      onPressed: () {
        showDialog(context: ctxt, builder: (ctx) => ModalContainerChooser());
      });
}
