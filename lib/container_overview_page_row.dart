import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'rescue_image.dart';

class ContainerOverviewPageRow {
  TableRow build({required RescueContainer container, required Function onClick}) =>
      TableRow(children: [
        InkWell(
            onTap: () => onClick(container),
            child: RescueImage('edit_icon.png')),
        RescueImage(container.imagePath),
        _rowText(container.name ?? ""),
        _rowText("1"),
        _rowText("2")
      ]);

  _rowText(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontFamily: 'Inter',
        ),
      );
}
