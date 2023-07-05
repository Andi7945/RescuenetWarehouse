import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/operational_status.dart';

import 'item.dart';

class IndicatorOperationalStatus extends StatelessWidget {
  final OperationalStatus _operationalStatus;

  IndicatorOperationalStatus(this._operationalStatus);

  @override
  Widget build(BuildContext context) {
    if (_operationalStatus == OperationalStatus.needsRepair) {
      return _filled("Repair", Color(0xFFE0A348));
    }
    if (_operationalStatus == OperationalStatus.toBeReplaced) {
      return _filled("Re\nplace", Color(0xFFE0A348));
    }
    return _empty();
  }

  _filled(String text, Color color) {
    return Container(
        width: 46,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ));
  }

  Widget _empty() {
    return const SizedBox(width: 46, height: 48);
  }
}