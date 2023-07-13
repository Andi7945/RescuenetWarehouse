import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item_edit_page_additional_information.dart';
import 'package:rescuenet_warehouse/item_edit_page_amounts.dart';
import 'package:rescuenet_warehouse/item_edit_page_notes.dart';

import 'item.dart';
import 'item_edit_page_meta_data.dart';

class ItemEditPage extends StatefulWidget {
  final Item item;

  @override
  State createState() => _ItemEditPageState();

  ItemEditPage(this.item);
}

class _ItemEditPageState extends State<ItemEditPage> {
  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return Container(
      width: 1664,
      height: 1013,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemEditPageMetaData(),
                const SizedBox(height: 10),
                ItemEditPageAmounts(),
                const SizedBox(height: 10),
                ItemEditPageAdditionalInformation()
              ],
            ),
          ),
          const SizedBox(width: 10),
          ItemEditPageNotes(widget.item),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
