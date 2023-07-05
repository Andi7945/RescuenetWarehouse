import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/operational_status.dart';

import 'indicator_expiring_date.dart';
import 'indicator_operational_status.dart';
import 'indicator_sign.dart';
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
          Row(children: [...signs.map((sign) => IndicatorSign(sign: sign))]),
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
