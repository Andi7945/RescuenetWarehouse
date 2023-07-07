import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'rescue_image.dart';

class ContainerOverviewPageRow {
  build(RescueContainer container) => TableRow(children: [
        RescueImage('edit_icon.png'),
        const SizedBox(width: 16),
        RescueImage(container.imagePath),
        const SizedBox(width: 16),
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
