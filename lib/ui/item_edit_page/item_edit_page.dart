import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_additional_information.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_amounts.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_base_information.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_signs.dart';

import '../../models/item.dart';
import '../../state/current_item_notifier.dart';
import 'item_edit_page_notes.dart';

class ItemEditPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    var item = ref.watch(currentItemNotifierProvider);
    if (item == null) {
      return CircularProgressIndicator();
    }
    return _body(item);
  }

  _body(Item item) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          children: [
            _lane(Column(
              children: [
                ItemEditPageBaseInformation(),
                const SizedBox(height: 8),
                ItemEditPageAmounts(item: item),
                const SizedBox(height: 8),
                ItemEditPageAdditionalInformation()
              ],
            )),
            _lane(Column(children: [ItemEditPageNotes(), ItemEditPageSigns()])),
          ],
        ));
  }

  Widget _lane(Widget w) =>
      Container(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: w);
}
