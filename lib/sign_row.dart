import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';

import 'indicator_expiring_date.dart';
import 'indicator_operational_status.dart';
import 'models/sign.dart';

class SignRow extends StatelessWidget {
  final List<Sign> signs;
  final DateTime? nextExpiringDate;
  final OperationalStatus operationalStatus;
  final bool isColdChain;

  SignRow(this.signs, this.nextExpiringDate, this.operationalStatus,
      this.isColdChain);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IndicatorExpiringDate(nextExpiringDate),
          IndicatorOperationalStatus(operationalStatus),
          ...signs.map((sign) => RescueImage(sign.imagePath, 40, 40)),
          isColdChain ? RescueImage("coldchain.png", 40, 40) : Container()
        ],
      ),
    );
  }
}
