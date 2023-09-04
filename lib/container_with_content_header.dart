import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_dao.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/rescue_box_module_destination.dart';
import 'package:rescuenet_warehouse/rescue_box_sequential_build.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'item_utils.dart';
import 'rescue_container.dart';
import 'item.dart';
import 'operational_status.dart';
import 'sign.dart';
import 'sign_row.dart';

class ContainerWithContentHeader extends StatelessWidget {
  final RescueContainer _container;
  final Map<Item, int> _items;

  ContainerWithContentHeader(this._container, this._items);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    return Container(
      width: 420,
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
          SignRow(
              _signs(), _nextExpired(), _operationalStatus(), _isColdChain()),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RescueBoxSequentialBuild(_container),
                RescueBoxModuleDestination(_container),
              ],
            ),
          ),
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
          _checkboxWithLabel("Deploy", _deployNotifier(context)),
          Flexible(
              child: RescueText.normal(
                  _container.printName, FontWeight.w700, TextAlign.center)),
          _checkboxWithLabel("Ready", _readyNotifier(context))
        ],
      ),
    );
  }

  _deployNotifier(BuildContext context) {
    var ifier = ValueNotifier(_container.toDeploy);
    ifier.addListener(() {
      var updated = ContainerDao.fromContainer(
          RescueContainer.from(container: _container, toDeploy: ifier.value));
      Provider.of<ContainerService>(context, listen: false)
          .updateContainer(updated);
    });
    return ifier;
  }

  _readyNotifier(BuildContext context) {
    var ifier = ValueNotifier(_container.isReady);
    ifier.addListener(() {
      var updated = ContainerDao.fromContainer(
          RescueContainer.from(container: _container, isReady: ifier.value));
      Provider.of<ContainerService>(context, listen: false)
          .updateContainer(updated);
    });
    return ifier;
  }

  Widget _checkboxWithLabel(String text, ValueNotifier<bool> changer) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText(20, text, textAlign: TextAlign.center),
          _checkbox(changer),
        ],
      ),
    );
  }

  _checkbox(ValueNotifier<bool> changer) {
    return Transform.scale(
      scale: 2.5,
      child: Checkbox(
        value: changer.value,
        onChanged: (bool? value) {
          changer.value = value ?? false;
        },
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

  List<Sign> _signs() {
    return _items.keys.expand((i) => i.signs).toList();
  }

  DateTime? _nextExpired() {
    var dates = _items.keys.expand((element) => element.expiringDates).toList();
    if (dates.isEmpty) {
      return null;
    }
    dates.sort();
    return dates.first;
  }

  _operationalStatus() {
    var status = _items.keys.map((e) => e.operationalStatus).toSet();
    if (status.contains(OperationalStatus.toBeReplaced)) {
      return OperationalStatus.toBeReplaced;
    }
    if (status.contains(OperationalStatus.needsRepair)) {
      return OperationalStatus.needsRepair;
    }
    return OperationalStatus.deployable;
  }

  bool _isColdChain() => _items.keys.any((itm) => itm.isColdChain);
}
