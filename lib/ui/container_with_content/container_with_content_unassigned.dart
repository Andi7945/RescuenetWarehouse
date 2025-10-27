import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/assignable_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../models/item.dart';
import '../item_card.dart';

class ContainerWithContentUnassigned extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignableItemsAsync = ref.watch(assignableItemsAsyncProvider);

    return assignableItemsAsync.when(
      data: (assignableItems) => ListView(
        shrinkWrap: true,
        children: [
          _header(),
          ..._sortedEntries(
            assignableItems,
          ).map((e) => ItemCard(e.key, e.value, true)),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('Error loading unassigned items: $error'),
          ],
        ),
      ),
    );
  }

  _header() {
    return Container(
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Center(child: RescueText.normal("Unassigned", FontWeight.w700)),
      ),
    );
  }

  List<MapEntry<Item, int>> _sortedEntries(Map<Item, int> assignable) {
    var entries = assignable.entries.toList();
    entries.sort((a, b) => (a.key.name ?? "").compareTo(b.key.name ?? ""));
    return entries;
  }
}
