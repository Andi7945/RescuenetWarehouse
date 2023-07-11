import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';
import 'package:rescuenet_warehouse/sequential_build.dart';

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
    return _body();
  }

  _body() {
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
          Container(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _checkboxWithLabel("Deploy"),
                Flexible(
                    child: _textBold(
                        _container.name ?? "NO NAME", 24, TextAlign.center)),
                _checkboxWithLabel("Ready")
              ],
            ),
          ),
          Container(
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
          ),
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

  _sumWeight() {
    return _items.entries
        .fold(_container.type.emptyWeight,
            (prev, e) => prev + (e.key.weight * e.value))
        .toStringAsFixed(2);
  }

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

  Widget _checkboxWithLabel(String text) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _text(text, 20, TextAlign.center),
          _check1(false),
        ],
      ),
    );
  }

  _check1(bool checked) {
    return Transform.scale(
      scale: 2.5,
      child: Checkbox(
        value: checked,
        onChanged: (bool? value) {
          // rnItem.checked = value!;
          // rnItemsProvider.updateRNItemInFB(rnItem);
        },
      ),
    );
  }

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
        color: _sequentialBuildColor(),
        shape: const RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _text('Sequential Build', 12),
          _textBold(_sequentialBuildName(), 16)
        ],
      ),
    );
  }

  Color _sequentialBuildColor() {
    if (_container.sequentialBuild == SequentialBuild.firstBuild) {
      return const Color.fromRGBO(255, 245, 0, 1);
    }
    if (_container.sequentialBuild == SequentialBuild.laterBuild) {
      return const Color.fromRGBO(0, 255, 41, 1);
    }
    if (_container.sequentialBuild == SequentialBuild.supplies) {
      return const Color.fromRGBO(0, 250, 250, 1);
    }
    return const Color(0xFFFFF400);
  }

  String _sequentialBuildName() {
    if (_container.sequentialBuild == SequentialBuild.firstBuild) {
      return "First Build";
    }
    if (_container.sequentialBuild == SequentialBuild.laterBuild) {
      return "Later Build";
    }
    if (_container.sequentialBuild == SequentialBuild.supplies) {
      return "Supplies";
    }
    return "Pre Build";
  }
}
