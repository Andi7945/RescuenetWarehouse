import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/current_item_assignments_not_null_notifier.dart';
import 'package:rescuenet_warehouse/state/current_item_assignments_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_amounts_add_container.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../models/item.dart';
import '../../models/rescue_container.dart';
import '../../state/current_item_notifier.dart';
import 'item_edit_page_amounts_row.dart';

class ItemEditPageAmounts extends ConsumerStatefulWidget {
  final Item item;

  ItemEditPageAmounts({super.key, required this.item});

  @override
  ConsumerState createState() => _ItemEditPageAmountsState();
}

class _ItemEditPageAmountsState extends ConsumerState<ItemEditPageAmounts> {
  Set<RescueContainer> haveBeenUsed = {};

  @override
  Widget build(BuildContext context) {
    var usedContainer = ref.watch(
      currentItemAssignmentsNotNullNotifierProvider,
    );
    var used = usedContainer.values.fold(0, (prev, e) => prev + e);
    haveBeenUsed.addAll(usedContainer.keys);

    var sorted = haveBeenUsed.toList();
    sorted.sort((a, b) => a.number.compareTo(b.number));

    int remaining = widget.item.totalAmount - used;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RescueText.slim('Amounts: '),
              ItemEditPageAmountsAddContainer(haveBeenUsed),
            ],
          ),
          ...sorted.map(
            (c) => _itemEditPageAmountsRow(c, usedContainer[c] ?? 0),
          ),
          ItemEditPageAmountsRow('Remaining', remaining),
          _separator(),
          ItemEditPageAmountsRow(
            'Total',
            widget.item.totalAmount,
            (t) => _changeTotal(context, t),
          ),
        ],
      ),
    );
  }

  _itemEditPageAmountsRow(RescueContainer cont, int previousAmount) {
    var fnChange =
        previousAmount == 0
            ? (a) => ref
                .read(currentItemAssignmentsNotifierProvider.notifier)
                .addContainerAssignment(cont.id, a)
            : (a) => ref
                .read(currentItemAssignmentsNotifierProvider.notifier)
                .setAmount(cont.id, a);
    return ItemEditPageAmountsRow(cont.printName, previousAmount, fnChange);
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

  _changeTotal(BuildContext context, int newAmount) {
    var updated = widget.item.copyWith(totalAmount: newAmount);
    ref.read(currentItemNotifierProvider.notifier).update(updated);
  }
}
