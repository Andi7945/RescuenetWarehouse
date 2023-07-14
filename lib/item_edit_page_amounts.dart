import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'item.dart';
import 'store.dart';

class ItemEditPageAmounts extends StatelessWidget {
  final Item item;
  final Map<RescueContainer, int> containerWithAssignments;

  ItemEditPageAmounts(this.item, this.containerWithAssignments);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    var remaining = item.totalAmount -
        containerWithAssignments.values
            .fold(0, (previousValue, element) => previousValue + element);
    return Container(
      width: 562,
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RescueText.slim('Amounts: '),
          ...containerWithAssignments.entries.map((e) => _container(
              e.key.name!,
              "${e.value}",
              () => _increase(context, e.key.id),
              () => _reduce(context, e.key.id))),
          _container('Remaining', "$remaining"),
          Container(
            width: 239,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
            ),
          ),
          _container(
              'Total',
              "${item.totalAmount}",
              () => _increaseTotal(context),
              () => _reduceTotal(context)),
        ],
      ),
    );
  }

  Widget _container(String label, String count,
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
                        onPressed: fnReduce, child: RescueText.normal("-")),
                  const SizedBox(width: 10),
                  RescueText.normal(count),
                  const SizedBox(width: 10),
                  if (fnIncrease != null)
                    TextButton(
                        onPressed: fnIncrease, child: RescueText.normal("+")),
                ],
              ),
            ),
          ],
        ));
  }

  _reduce(BuildContext context, String containerId) {
    Provider.of<Store>(context, listen: false).reduce(item, containerId);
  }

  _increase(BuildContext context, String containerId) {
    Provider.of<Store>(context, listen: false).increase(item, containerId);
  }

  _reduceTotal(BuildContext context) {
    Provider.of<Store>(context, listen: false)
        .updateItem(Item.from(item: item, totalAmount: item.totalAmount - 1));
  }

  _increaseTotal(BuildContext context) {
    Provider.of<Store>(context, listen: false)
        .updateItem(Item.from(item: item, totalAmount: item.totalAmount + 1));
  }
}
