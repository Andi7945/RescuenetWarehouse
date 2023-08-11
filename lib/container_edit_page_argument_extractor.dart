import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_edit_page.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'container_dao.dart';
import 'container_options.dart';
import 'menu.dart';
import 'store.dart';

class ContainerEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.containerOverview),
      Expanded(child: _body(containerId))
    ]));
  }

  _body(String id) => Consumer3<ContainerOptions, Store, ContainerService>(
      builder: (ctxt, options, store, service, _) => _page(
          service.containers().firstWhere((c) => c.id == id),
          (c) => store.updateContainer(c),
          options));

  _page(RescueContainer container, ValueChanged<ContainerDao> updateContainer,
      ContainerOptions containerOptions) {
    var cont = ValueNotifier(container);
    cont.addListener(() {
      updateContainer(ContainerDao.fromContainer(cont.value));
    });
    return ContainerEditPage(cont, containerOptions);
  }
}
