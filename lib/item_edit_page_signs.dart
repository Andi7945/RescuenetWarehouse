import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_edit_page_signs_single.dart';

import 'item.dart';
import 'item_service.dart';
import 'main.dart';
import 'rescue_text.dart';
import 'sign.dart';

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
    return Column(children: [_addButton(context), ..._signs(context)]);
  }

  _addButton(BuildContext context) {
    return FilledButton(
        onPressed: () => _changeItem(context, "", Sign(id: uuid.v4())),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RescueText.headline('+ '),
              RescueText.slim("Add Sign")
            ]));
  }

  List<ItemEditPageSignsSingle> _signs(BuildContext context) {
    return item.signs
        .map((s) =>
            ItemEditPageSignsSingle(s, (u) => _changeItem(context, s.id, u)))
        .toList();
  }

  _changeItem(BuildContext context, String idToReplace, Sign? updated) {
    var updatedSigns = [
      ...item.signs.where((element) => element.id != idToReplace)
    ];
    if (updated != null) {
      updatedSigns.add(updated);
    }
    updatedSigns.sort((s1, s2) => s1.id.compareTo(s2.id));
    var updatedItem = item.copyWith(signs: updatedSigns);
    Provider.of<ItemService>(context, listen: false).updateItem(updatedItem);
  }
}
