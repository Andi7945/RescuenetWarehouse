import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_edit_page_signs_single.dart';

import 'item.dart';
import 'sign.dart';
import 'store.dart';

class ItemEditPageSigns extends StatelessWidget {
  final Item item;

  ItemEditPageSigns(this.item);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
            width: 562,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
            ),
            child: _body(context)));
  }

  Widget _body(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        children: item.signs
            .map((s) =>
                ItemEditPageSignsSingle(s, (u) => _changeItem(context, u)))
            .toList());
  }

  _changeItem(BuildContext context, Sign updated) {
    var updatedSigns = [
      updated,
      ...item.signs.where((element) => element.id != updated.id)
    ];
    updatedSigns.sort((s1, s2) => s1.id.compareTo(s2.id));
    var updatedItem = Item.from(item: item, signs: updatedSigns);
    Provider.of<Store>(context, listen: false).updateItem(updatedItem);
  }
}
