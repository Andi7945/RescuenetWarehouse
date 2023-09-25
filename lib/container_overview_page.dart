import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_overview_page_card.dart';
import 'package:rescuenet_warehouse/menu_option.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'container_service.dart';
import 'menu.dart';
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
        FilledButton.tonalIcon(
            onPressed: () async {
              var cont = await service.newContainer();
              Navigator.pushNamed(context, routeContainerEditPage,
                  arguments: cont.id);
            },
            icon: const Icon(Icons.add),
            label: RescueText.normal("Add"))
      ]));

  _body(context, ContainerService service) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(spacing: 8.0, runSpacing: 8.0, children: [
        ...service
            .containers()
            .map((c) => ContainerOverviewPageCard(c))
            .toList()
      ]));
}
