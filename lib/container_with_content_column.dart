import 'package:flutter/material.dart';

import 'item.dart';
import 'operational_status.dart';
import 'sign.dart';
import 'sign_row.dart';

class ContainerWithContentColumn extends StatelessWidget {
  final List<Item> _items;

  ContainerWithContentColumn(this._items);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: _body());
  }

  _body() {
    return Container(
      width: 360,
      height: 339,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
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
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _checkboxWithLabel("Deploy"),
                Expanded(
                  child: Text(
                    '1 Office supplies',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _checkboxWithLabel("Ready")
              ],
            ),
          ),
          Container(
            width: 360,
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 91,
                  height: 73,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/91x73"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Euro crate',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 143,
                          height: 39,
                          child: Text(
                            '60x40x32',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
                      Text(
                        'Weight',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '14.7 kg',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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

  Container _checkboxWithLabel(String text) {
    return Container(
      width: 72,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
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
    return _items.expand((i) => i.signs).toList();
  }

  DateTime? _nextExpired() {
    var dates = _items.expand((element) => element.expiringDates).toList();
    if (dates.isEmpty) {
      return null;
    }
    dates.sort();
    return dates.first;
  }

  _operationalStatus() {
    var status = _items.map((e) => e.operationalStatus).toSet();
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
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Module Destination',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Office',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
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
        color: Color(0xFFFFF400),
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Sequential Build',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            'First build',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
