import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_box_current_location.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'rescue_box_module_destination.dart';
import 'rescue_box_sequential_build.dart';
import 'rescue_image.dart';
import 'routes.dart';

class ContainerOverviewPageCard extends StatelessWidget {
  final RescueContainer container;

  ContainerOverviewPageCard(this.container, {super.key});

  @override
  Widget build(BuildContext context) => _body(context);

  _body(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeContainerEditPage,
              arguments: container.id);
        },
        child: Container(
            width: 420,
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _nameRow(),
              _typeAndLocationRow(),
              _priorityAndDestination()
            ])));
  }

  Widget _nameRow() => Flexible(
      child: RescueText.normal(
          container.printName, FontWeight.w700, TextAlign.center));

  Widget _typeAndLocationRow() => Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RescueImage(container.type?.imagePath),
            _measurements(),
            RescueBoxCurrentLocation(container)
          ]));

  Widget _measurements() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RescueText.slim(container.type?.name),
            const SizedBox(height: 4),
            RescueText.slim(container.type?.measurements),
          ],
        ),
      ),
    );
  }

  Widget _priorityAndDestination() {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RescueBoxSequentialBuild(container),
          RescueBoxModuleDestination(container),
        ],
      ),
    );
  }
}
