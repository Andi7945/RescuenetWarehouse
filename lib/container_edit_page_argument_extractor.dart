import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_edit_page.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/widget/rescue_navigation_drawer.dart';

import 'container_dao.dart';
import 'container_options.dart';

class ContainerEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(title: const Text("Container page")),
        drawer: RescueNavigationDrawer(),
        body: _body(containerId));
  }

  _body(String id) => Consumer2<ContainerOptions, ContainerService>(
      builder: (ctxt, options, service, _) => _page(
          service.containers().firstWhere((c) => c.id == id),
          (c) => service.updateContainer(c),
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
