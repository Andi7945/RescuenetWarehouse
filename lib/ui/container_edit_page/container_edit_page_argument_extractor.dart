import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/ui/container_edit_page/container_edit_page.dart';
import 'package:rescuenet_warehouse/services/container_service.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';

import '../../models/container_dao.dart';
import '../../models/container_options.dart';

class ContainerEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    return Consumer2<ContainerOptions, ContainerService>(
        builder: (ctxt, options, service, _) {
      var container =
          service.containers().firstWhere((c) => c.id == containerId);
      return Scaffold(
          appBar: AppBar(title: Text("Edit container ${container.number}")),
          drawer: RescueNavigationDrawer(),
          body: _page(container, (c) => service.updateContainer(c), options));
    });
  }

  _page(RescueContainer container, ValueChanged<ContainerDao> updateContainer,
      ContainerOptions containerOptions) {
    var cont = ValueNotifier(container);
    cont.addListener(() {
      updateContainer(ContainerDao.fromContainer(cont.value));
    });
    return ContainerEditPage(cont, containerOptions);
  }
}
