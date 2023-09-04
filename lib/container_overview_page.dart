import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_overview_page_card.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'container_service.dart';
import 'menu.dart';
import 'rescue_container.dart';
import 'rescue_text.dart';

class ContainerOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<ContainerService>(
            builder: (ctxt, service, _) => Column(children: [
                  Menu(MenuOption.containerOverview),
                  _buttons(context, service),
                  Expanded(child: _body(context, service))
                ])));
  }

  _buttons(BuildContext context, ContainerService service) => Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(children: [
        TextButton(
            onPressed: () async {
              var cont = await service.newContainer();
              Navigator.pushNamed(context, routeContainerEditPage,
                  arguments: cont.id);
            },
            child: RescueText.normal("Add container"))
      ]));

  _body(context, ContainerService service) {
    return _grid(service.containers());
  }

  _grid(List<RescueContainer> containers) => GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        childAspectRatio: 2,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: <Widget>[
          ...containers.map((c) => ContainerOverviewPageCard(c)).toList()
        ],
      );
}
