import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_card.dart';

import '../../models/item.dart';
import '../../models/rescue_container.dart';
import 'container_with_content_header.dart';

class ContainerWithContentColumn extends ConsumerWidget {
  final RescueContainer _container;

  ContainerWithContentColumn(this._container);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var assignments = ref
        .watch(allAssignmentsNotifierProvider.notifier)
        .byContainer(_container.id);
    var items = Map.fromEntries(assignments.map((a) {
      var i = ref.watch(allItemsNotifierProvider.notifier).byId(a.itemId);
      if (i != null && a.count > 0) {
        return MapEntry(i, a.count);
      }
    }).nonNulls);
    return ListView(
      shrinkWrap: true,
      children: [
        ContainerWithContentHeader(_container, items),
        ..._sortedEntries(items).map((e) => ItemCard(e.key, e.value, true))
      ],
    );
  }

  List<MapEntry<Item, int>> _sortedEntries(Map<Item, int> items) {
    var entries = items.entries.toList();
    entries.sort((a, b) => (a.key.name ?? "").compareTo(b.key.name ?? ""));
    return entries;
  }
}
