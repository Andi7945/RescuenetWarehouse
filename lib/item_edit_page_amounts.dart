import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_edit_page_amounts_add_container.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'item.dart';
import 'store.dart';

class ItemEditPageAmounts extends StatefulWidget {
  final Item item;
  final Map<RescueContainer, int> containerWithAssignments;

  ItemEditPageAmounts(this.item, this.containerWithAssignments);

  @override
  State createState() => _ItemEditPageAmountsState();
}

class _ItemEditPageAmountsState extends State<ItemEditPageAmounts> {
  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    var remaining = widget.item.totalAmount -
        widget.containerWithAssignments.values
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            RescueText.slim('Amounts: '),
            ItemEditPageAmountsAddContainer(widget.item),
          ]),
          ..._sortedEntries().map((e) => _container(
              e.key.name!,
              "${e.value}",
              () => _increase(context, e.key.id),
              () => _reduce(context, e.key.id))),
          _container('Remaining', "$remaining"),
          _separator(),
          _container('Total', "${widget.item.totalAmount}",
              () => _increaseTotal(context), () => _reduceTotal(context)),
        ],
      ),
    );
  }

  List<MapEntry<RescueContainer, int>> _sortedEntries() {
    var x = widget.containerWithAssignments.entries.toList();
    x.sort((a, b) => a.key.id.compareTo(b.key.id));
    return x;
  }

  Container _separator() {
    return Container(
      width: 239,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.50,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
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
                        onPressed: fnReduce, child: RescueText.slim("-")),
                  const SizedBox(width: 10),
                  RescueText.normal(count),
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

  _reduce(BuildContext context, String containerId) {
    Provider.of<Store>(context, listen: false).reduce(widget.item, containerId);
  }

  _increase(BuildContext context, String containerId) {
    Provider.of<Store>(context, listen: false).increase(widget.item, containerId);
  }

  _reduceTotal(BuildContext context) {
    Provider.of<Store>(context, listen: false)
        .updateItem(Item.from(item: widget.item, totalAmount: widget.item.totalAmount - 1));
  }

  _increaseTotal(BuildContext context) {
    Provider.of<Store>(context, listen: false)
        .updateItem(Item.from(item: widget.item, totalAmount: widget.item.totalAmount + 1));
  }
}
