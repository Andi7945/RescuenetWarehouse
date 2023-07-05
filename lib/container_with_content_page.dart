import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
import 'package:rescuenet_warehouse/data_mocks.dart';

class ContainerWithContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      ContainerWithContentColumn(
          container_office, {item_fire: 2, item_chair: 13, item_desk: 1}),
      ContainerWithContentColumn(
          container_power, {item_generator: 1, item_fire: 2}),
      ContainerWithContentColumn(
          container_medical, {item_cooler: 1, item_para: 1000, item_splint: 1})
    ]);
  }
}
