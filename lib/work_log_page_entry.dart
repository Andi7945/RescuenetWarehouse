import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/log_entry_expanded.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'item.dart';
import 'rescue_image.dart';

TableRow asTableRow(LogEntryExpanded entry) {
  return TableRow(children: [
    _item(entry.item),
    _container(entry.container),
    RescueText.normal("${entry.count}")
  ]);
}

Widget _item(Item item) => Row(
      children: [
        RescueImage(item.imagePath),
        RescueText.normal(item.name ?? ""),
      ],
    );

Widget _container(RescueContainer? container) => Row(children: [
      RescueImage(container?.imagePath),
      RescueText.normal(container?.name ?? ""),
    ]);
