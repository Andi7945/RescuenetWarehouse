import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import '../../routes.dart';
import 'container_overview_page_card_content.dart';

class ContainerOverviewPageCard extends StatelessWidget {
  final RescueContainer container;

  ContainerOverviewPageCard(this.container, {super.key});

  @override
  Widget build(BuildContext context) => _body(context);

  _body(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          routeContainerEditPage,
          arguments: container.id,
        );
      },
      child: ContainerOverviewPageCardContent(container, 410),
    );
  }
}
