import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/assignable_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../models/item.dart';
import '../item_card.dart';

class ContainerWithContentUnassigned extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
        shrinkWrap: true,
        children: [
          _header(),
          ..._sortedEntries(ref.watch(assignableItemsNotifierProvider))
              .map((e) => ItemCard(e.key, e.value, true))
        ],
      );

  _header() {
    return Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
        ),
        child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Center(
                child: RescueText.normal("Unassigned", FontWeight.w700))));
  }

  List<MapEntry<Item, int>> _sortedEntries(Map<Item, int> assignable) {
    var entries = assignable.entries.toList();
    entries.sort((a, b) => (a.key.name ?? "").compareTo(b.key.name ?? ""));
    return entries;
  }
}
