import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item_utils.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/ui/container_with_content/container_with_content_header_bottom.dart';
import 'package:rescuenet_warehouse/ui/rescue_image.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../routes.dart';
import 'container_with_content_header_checkbox.dart';

class ContainerWithContentHeader extends StatelessWidget {
  final RescueContainer _container;
  final Map<Item, int> _items;

  ContainerWithContentHeader(this._container, this._items);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeContainerEditPage,
              arguments: _container.id);
        },
        child: _body(context));
  }

  _body(BuildContext context) {
    return Container(
      width: 400,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _nameAndCheckboxes(context),
          _basicInformation(),
          ContainerWithContentHeaderBottom(
              container: _container, items: _items),
        ],
      ),
    );
  }

  Container _nameAndCheckboxes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ContainerWithContentHeaderCheckbox("Deploy", _container.toDeploy,
              (v) => _container.copyWith(toDeploy: v)),
          Flexible(child: RescueText.headline(_container.printName)),
          ContainerWithContentHeaderCheckbox("Ready", _container.isReady,
              (v) => _container.copyWith(isReady: v))
        ],
      ),
    );
  }

  Container _basicInformation() {
    return Container(
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RescueImage(_container.type?.imagePath),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RescueText.slim(_container.type?.name),
                  const SizedBox(height: 10),
                  RescueText.slim(_container.type?.measurements),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RescueText.slim('Weight'),
              const SizedBox(height: 10),
              RescueText(20, "${_sumWeight()} kg")
            ],
          ),
        ],
      ),
    );
  }

  _sumWeight() => sumItemWeight(_container, _items).toStringAsFixed(2);
}
