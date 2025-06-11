import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../rescue_image.dart';

TableRow header() => TableRow(children: [
      RescueText.normal("Name", FontWeight.w700),
      RescueText.normal("Amount", FontWeight.w700),
      RescueText.normal("User", FontWeight.w700),
    ]);

TableRow item(String? itemName, int count, String user) => TableRow(
      children: [
        RescueText.normal(itemName ?? ""),
        RescueText.normal("$count"),
        RescueText.normal(user)
      ],
    );

TableRow _container(RescueContainer? container) => TableRow(children: [
      _imageCell(container?.type?.imagePath, 80, 160),
      RescueText.slim(container?.printName ?? ""),
      Container()
    ]);

Widget _imageCell(
        String? path, double leftPadding, double rightPadding) =>
    Padding(
        padding: EdgeInsets.only(
            top: 8, bottom: 8, left: leftPadding, right: rightPadding),
        child: RescueImage(path));
