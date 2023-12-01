import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_amount.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';


class ItemEditPageAmountsRow extends StatelessWidget {
  final String label;
  final int amount;
  final Function(int)? changeAmount;

  ItemEditPageAmountsRow(this.label, this.amount, [this.changeAmount]);

  @override
  Widget build(BuildContext context) {
    var fnChangeAmount = changeAmount;
    if (fnChangeAmount != null) {
      return _row(label, _changeableAmount(fnChangeAmount));
    }
    return _row(label, RescueText.normal("$amount"));
  }

  Widget _row(String label, Widget rightSide) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RescueText.slim(label),
            Container(
                height: 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
                ),
                child: rightSide)
          ]));

  Widget _changeableAmount(Function(int) fnChangeAmount) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () => fnChangeAmount(amount - 1),
              icon: const Icon(Icons.remove)),
          const SizedBox(width: 4),
          SizedBox(
              width: 60,
              child:
                  RescueInputAmount(onChange: fnChangeAmount, amount: amount)),
          const SizedBox(width: 4),
          IconButton(
              onPressed: () => fnChangeAmount(amount + 1),
              icon: const Icon(Icons.add))
        ],
      );
}
