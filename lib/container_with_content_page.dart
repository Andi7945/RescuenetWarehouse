import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_with_content_column.dart';
import 'package:rescuenet_warehouse/data_mocks.dart';

class ContainerWithContentPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ContainerWithContentColumn([
      item1,
      item2
    ]);
  }
}
