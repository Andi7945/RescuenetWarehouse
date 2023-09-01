import 'package:flutter/material.dart';

import 'rescue_input_amount.dart';
import 'rescue_text.dart';

class ItemEditPageAmountsRow extends StatefulWidget {
  final String label;
  final int amount;
  final Function(int)? changeAmount;

  ItemEditPageAmountsRow(this.label, this.amount, [this.changeAmount]);

  @override
  State createState() => _ItemEditPageAmountsRow();
}

class _ItemEditPageAmountsRow extends State<ItemEditPageAmountsRow> {
  late ValueNotifier<int> notifier;

  @override
  void initState() {
    super.initState();

    notifier = _createNotifier();
  }

  @override
  Widget build(BuildContext context) {
    var fnChangeAmount = widget.changeAmount;
    if (fnChangeAmount != null) {
      return _container(
          widget.label,
          SizedBox(width: 30, child: RescueInputAmount(notifier: notifier)),
          () => fnChangeAmount(widget.amount + 1),
          () => fnChangeAmount(widget.amount - 1));
    }
    return _container(widget.label, RescueText.normal("${widget.amount}"));
  }

  ValueNotifier<int> _createNotifier() {
    var notifier = ValueNotifier(widget.amount);
    var fnChangeAmount = widget.changeAmount;
    if (fnChangeAmount != null) {
      notifier.addListener(() {
        fnChangeAmount(notifier.value);
      });
    }
    return notifier;
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
