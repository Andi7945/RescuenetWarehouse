import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';

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
      height: 339,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 360,
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _checkboxWithLabel("Deploy"),
                _textBold(_container.name ?? "NO NAME", 24, TextAlign.center),
                _checkboxWithLabel("Ready")
              ],
            ),
          ),
          Container(
            width: 360,
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
                        SizedBox(
                            width: 143,
                            height: 39,
                            child: _text(_container.type.measurements, 16)),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 86,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _text('Weight', 16),
                      const SizedBox(height: 10),
                      _text("${_sumWeight()} kg", 20)
                    ],
                  ),
                ),
              ],
            ),
          ),
          SignRow(_signs(), _nextExpired(), _operationalStatus()),
          Container(
            width: 360,
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
    return _items.entries.fold(_container.type.emptyWeight,
        (prev, e) => prev + (e.key.weight * e.value));
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

  Container _checkboxWithLabel(String text) {
    return Container(
      width: 72,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _text(text, 20, TextAlign.center),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape:
                        RoundedRectangleBorder(side: BorderSide(width: 0.50)),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          _textBold('Office', 24),
        ],
      ),
    );
  }

  Container _sequentialBuild() {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Color(0xFFFFF400),
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_text('Sequential Build', 12), _textBold('First build', 16)],
      ),
    );
  }
}
