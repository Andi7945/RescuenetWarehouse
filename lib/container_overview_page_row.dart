import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'rescue_image.dart';

class ContainerOverviewPageRow {
  TableRow build(
          {required RescueContainer container, required Function onClick}) =>
      TableRow(children: [
        InkWell(
            onTap: () => onClick(container),
            child: RescueImage('edit_icon.png')),
        RescueImage(container.type?.imagePath),
        RescueText.normal(container.name),
        RescueText.normal("1"),
        RescueText.normal("2")
      ]);
}
