import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text.dart';

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
            child: RescueInputText(
                maxLines: 20,
                initial: item.notes,
                onChange: (s) => _updateItem(context, item.copyWith(notes: s))),
          ),
        ],
      ),
    );
  }

  _updateItem<T>(BuildContext context, Item itm) =>
      Provider.of<ItemService>(context, listen: false).updateItem(itm);
}
