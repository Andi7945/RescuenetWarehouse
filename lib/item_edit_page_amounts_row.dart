import 'package:flutter/material.dart';

import 'rescue_input_amount.dart';
import 'rescue_text.dart';

class ItemEditPageAmountsRow extends StatelessWidget {
  final String label;
  final int amount;
  final Function(int)? changeAmount;

  ItemEditPageAmountsRow(this.label, this.amount, [this.changeAmount]);

  @override
  Widget build(BuildContext context) {
    var fnChangeAmount = changeAmount;
    if (fnChangeAmount != null) {
      return _container(
          label,
          SizedBox(
              width: 60,
              child:
                  RescueInputAmount(onChange: fnChangeAmount, amount: amount)),
          () => fnChangeAmount(amount + 1),
          () => fnChangeAmount(amount - 1));
    }
    return _container(label, RescueText.normal("$amount"));
  }

  Widget _container(String label, Widget number,
      [VoidCallback? fnIncrease, VoidCallback? fnReduce]) {
    return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RescueText.slim(label),
            const SizedBox(width: 10),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (fnReduce != null)
                    TextButton(
                        onPressed: fnReduce, child: RescueText.slim("-")),
                  const SizedBox(width: 10),
                  number,
                  const SizedBox(width: 10),
                  if (fnIncrease != null)
                    TextButton(
                        onPressed: fnIncrease, child: RescueText.slim("+")),
                ],
              ),
            ),
          ],
        ));
  }
}
