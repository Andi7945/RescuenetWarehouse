import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_signs_single.dart';

import '../../main.dart';
import '../rescue_text.dart';
import '../../models/sign.dart';

class ItemEditPageSigns extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: 562,
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
        ),
        child: _body(ref),
      ),
    );
  }

  Widget _body(WidgetRef ref) {
    return Column(children: [_addButton(ref), ..._signs(ref)]);
  }

  _addButton(WidgetRef ref) {
    return FilledButton(
      onPressed: () => _changeItem(ref, "", Sign(id: uuid.v4())),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [RescueText.headline('+ '), RescueText.slim("Add Sign")],
      ),
    );
  }

  List<ItemEditPageSignsSingle> _signs(WidgetRef ref) {
    var item = ref.watch(currentItemNotifierProvider);
    if (item == null) {
      return [];
    }
    return item.signs
        .map(
          (s) => ItemEditPageSignsSingle(s, (u) => _changeItem(ref, s.id, u)),
        )
        .toList();
  }

  _changeItem(WidgetRef ref, String idToReplace, Sign? updated) {
    var item = ref.watch(currentItemNotifierProvider);
    if (item == null) {
      return [];
    }
    var updatedSigns = [
      ...item.signs.where((element) => element.id != idToReplace),
    ];
    if (updated != null) {
      updatedSigns.add(updated);
    }
    updatedSigns.sort((s1, s2) => s1.id.compareTo(s2.id));
    var updatedItem = item.copyWith(signs: updatedSigns);
    ref.watch(currentItemNotifierProvider.notifier).update(updatedItem);
  }
}
