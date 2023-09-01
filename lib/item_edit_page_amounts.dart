import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_service.dart';
import 'package:rescuenet_warehouse/item_edit_page_amounts_add_container.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'item.dart';
import 'item_edit_page_amounts_row.dart';
import 'item_service.dart';

class ItemEditPageAmounts extends StatefulWidget {
  final Item item;
  final Map<RescueContainer, int> containerWithAssignments;

  ItemEditPageAmounts(this.item, this.containerWithAssignments);

  @override
  State createState() => _ItemEditPageAmountsState();
}

class _ItemEditPageAmountsState extends State<ItemEditPageAmounts> {
  // Saved so when decreasing to zero the entries are only removed after page reload
  Set<RescueContainer> knownContainers = {};

  @override
  Widget build(BuildContext context) {
    knownContainers.addAll(widget.containerWithAssignments.keys);
    return _body(context);
  }

  _body(BuildContext context) {
    int remaining = widget.item.totalAmount -
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
            ItemEditPageAmountsAddContainer(
                widget.item, knownContainers.map((e) => e.printName).toSet()),
          ]),
          ..._sortedEntries().map((e) => ItemEditPageAmountsRow(e.key.printName,
              e.value, (a) => _changeAmount(context, e.key, a))),
          ItemEditPageAmountsRow('Remaining', remaining),
          _separator(),
          ItemEditPageAmountsRow(
              'Total', widget.item.totalAmount, (t) => _changeTotal(context, t))
        ],
      ),
    );
  }

  List<MapEntry<RescueContainer, int>> _sortedEntries() {
    var x = knownContainers
        .map((e) => MapEntry(e, widget.containerWithAssignments[e] ?? 0))
        .toList();
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

  _changeAmount(
      BuildContext context, RescueContainer container, int newAmount) {
    if (widget.containerWithAssignments.containsKey(container)) {
      Provider.of<AssignmentService>(context, listen: false)
          .setAmount(widget.item, container.id, newAmount);
    } else {
      Provider.of<AssignmentService>(context, listen: false)
          .addContainer(container.id, widget.item);
    }
  }

  _changeTotal(BuildContext context, int newAmount) {
    Provider.of<ItemService>(context, listen: false)
        .updateItem(Item.from(item: widget.item, totalAmount: newAmount));
  }
}
