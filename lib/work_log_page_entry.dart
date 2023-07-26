import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/log_entry_expanded.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'rescue_image.dart';

List<TableRow> asTableRow(
    MapEntry<RescueContainer?, List<LogEntryExpanded>> entry) {
  return [_container(entry.key), ...entry.value.map(item).toList()];
}

TableRow header() => TableRow(children: [
  RescueText.normal("Name", FontWeight.w700),
  RescueText.normal("Amount", FontWeight.w700),
  RescueText.normal("User", FontWeight.w700),
]);

TableRow item(LogEntryExpanded entry) => TableRow(
      children: [
        RescueText.normal(entry.item.name ?? ""),
        RescueText.normal("${entry.count}"),
        RescueText.normal("Heinz")
      ],
    );

TableRow _container(RescueContainer? container) => TableRow(children: [
      _imageCell(container?.imagePath, 80, 160),
      RescueText.slim(container?.name ?? ""),
      Container()
    ]);

Widget _imageCell(
        String? path, double leftPadding, double rightPadding) =>
    Padding(
        padding: EdgeInsets.only(
            top: 8, bottom: 8, left: leftPadding, right: rightPadding),
        child: RescueImage(path));
