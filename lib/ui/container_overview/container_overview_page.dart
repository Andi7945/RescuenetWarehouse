import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page_card.dart';
import 'package:rescuenet_warehouse/routes.dart';

import '../../container_service.dart';
import '../rescue_navigation_drawer.dart';

class ContainerOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ContainerService>(
        builder: (ctxt, service, _) => Scaffold(
            appBar: AppBar(
              title: const Text("Container overview"),
              actions: [
                IconButton(
                    onPressed: () async {
                      var cont = await service.newContainer();
                      Navigator.pushNamed(context, routeContainerEditPage,
                          arguments: cont.id);
                    },
                    icon: const Icon(Icons.add))
              ],
            ),
            drawer: RescueNavigationDrawer(),
            body: _body(context, service)));
  }

  _body(context, ContainerService service) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(spacing: 8.0, runSpacing: 8.0, children: [
        ...service
            .containers()
            .map((c) => ContainerOverviewPageCard(c))
            .toList()
      ]));
}
