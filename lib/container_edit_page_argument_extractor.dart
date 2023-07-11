import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_edit_page.dart';

import 'menu.dart';
import 'store.dart';

class ContainerEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: Column(children: [Menu(), Expanded(child: _page(containerId))]));
  }

  _page(String id) => Consumer<Store>(
      builder: (ctxt, store, _) => ContainerEditPage(
          store.containerById(id), (c) => store.updateContainer(c)));
}
