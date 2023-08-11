import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_dao.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';

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
          SignRow(_signs(), _nextExpired(), _operationalStatus()),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sequentialBuild(),
                _moduleDestination(),
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
          Flexible(child: _textBold(_container.name, 24, TextAlign.center)),
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
      Provider.of<ContainerService>(context, listen: false).updateContainer(updated);
    });
    return ifier;
  }

  _readyNotifier(BuildContext context) {
    var ifier = ValueNotifier(_container.isReady);
    ifier.addListener(() {
      var updated = ContainerDao.fromContainer(
          RescueContainer.from(container: _container, isReady: ifier.value));
      Provider.of<ContainerService>(context, listen: false).updateContainer(updated);
    });
    return ifier;
  }

  Widget _checkboxWithLabel(String text, ValueNotifier<bool> changer) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _text(text, 20, TextAlign.center),
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
          RescueImage(_container.imagePath),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _text(_container.type.name, 16),
                  const SizedBox(height: 10),
                  _text(_container.type.measurements, 16),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text('Weight', 16),
              const SizedBox(height: 10),
              _text("${_sumWeight()} kg", 20)
            ],
          ),
        ],
      ),
    );
  }

  _sumWeight() => sumItemWeight(_container, _items.keys).toStringAsFixed(2);

  Text _text(String text, double fontSize, [TextAlign? textAlign]) => Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      );

  Text _textBold(String text, double fontSize, [TextAlign? textAlign]) => Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      );

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

  Container _moduleDestination() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _text('Module Destination', 16),
          const SizedBox(height: 10),
          _textBold(_container.moduleDestination ?? "", 24),
        ],
      ),
    );
  }

  Container _sequentialBuild() {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: _container.sequentialBuild.color,
        shape: const RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _text('Sequential Build', 12),
          _textBold(_container.sequentialBuild.displayName, 16)
        ],
      ),
    );
  }
}
