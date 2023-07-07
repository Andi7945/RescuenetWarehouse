import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_edit_page.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'menu.dart';

class ContainerEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var container =
        ModalRoute.of(context)!.settings.arguments as RescueContainer;
    return Scaffold(
        body: Column(children: [Menu(), Expanded(child: _page(container))]));
  }

  _page(RescueContainer container) => ContainerEditPage(container);
}
