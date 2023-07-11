import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_edit_page.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'container_options.dart';
import 'menu.dart';
import 'store.dart';

class ContainerEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: Column(children: [Menu(), Expanded(child: _body(containerId))]));
  }

  _body(String id) => Consumer<Store>(
      builder: (ctxt, store, _) => _page(store.containerById(id),
          (c) => store.updateContainer(c), store.containerOptions));

  _page(
      RescueContainer container,
      ValueChanged<RescueContainer> updateContainer,
      ContainerOptions containerOptions) {
    var cont = ValueNotifier(container);
    cont.addListener(() {
      updateContainer(cont.value);
    });
    return ContainerEditPage(cont, containerOptions);
  }
}
