import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/services/container_visibility_service.dart';
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page_card.dart';
import 'package:rescuenet_warehouse/routes.dart';

import '../../services/container_service.dart';
import '../rescue_navigation_drawer.dart';

class ContainerOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ContainerService, ContainerVisibilityService>(
        builder: (ctxt, service, visibilityService, _) => Scaffold(
            appBar: AppBar(
              title: const Text("Container overview"),
              actions: [
                IconButton(
                    onPressed: () async {
                      var cont = await service.newContainer();
                      Navigator.pushNamed(context, routeContainerEditPage,
                          arguments: cont.id);
                    },
                    icon: const Icon(Icons.add)),
                provideContainerFilterAction(visibilityService, ctxt),
              ],
            ),
            drawer: RescueNavigationDrawer(),
            body: _body(context, visibilityService)));
  }

  _body(context, ContainerVisibilityService service) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(spacing: 8.0, runSpacing: 8.0, children: [
        ..._sorted(service).map((c) => ContainerOverviewPageCard(c))
      ]));

  _sorted(ContainerVisibilityService service) {
    var containersWithVisibility = service.filteredContainer;
    containersWithVisibility.removeWhere((key, value) => !value);
    var containers = containersWithVisibility.keys.toList();
    containers.sort((a, b) => a.number.compareTo(b.number));
    return containers;
  }
}
