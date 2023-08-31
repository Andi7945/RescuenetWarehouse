import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/rescue_input.dart';

import 'item.dart';
import 'item_service.dart';

class ItemEditPageNotes extends StatelessWidget {
  final Item item;

  ItemEditPageNotes(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    return Container(
      width: 562,
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: RescueInput(
                maxLines: 20,
                initial: item.notes,
                onChange: _updateItem(
                    context, (String p0) => Item.from(item: item, notes: p0))),
          ),
        ],
      ),
    );
  }

  Function(T) _updateItem<T>(BuildContext context, Item Function(T) updateFn) =>
      (s) => Provider.of<ItemService>(context, listen: false)
          .updateItem(updateFn(s));
}
