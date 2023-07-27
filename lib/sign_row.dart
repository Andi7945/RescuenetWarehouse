import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';

import 'indicator_expiring_date.dart';
import 'indicator_operational_status.dart';
import 'sign.dart';

class SignRow extends StatelessWidget {
  final List<Sign> signs;
  final DateTime? nextExpiringDate;
  final OperationalStatus operationalStatus;

  SignRow(this.signs, this.nextExpiringDate, this.operationalStatus);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [...signs.map((sign) => RescueImage(sign.imagePath, 40, 40))]),
          Row(
            children: [
              IndicatorExpiringDate(nextExpiringDate),
              IndicatorOperationalStatus(operationalStatus),
            ],
          )
        ],
      ),
    );
  }
}
