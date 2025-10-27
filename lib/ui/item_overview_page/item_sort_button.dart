import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/models/item_sorting_options.dart';
import 'package:rescuenet_warehouse/state/items_current_sort_notifier.dart';

class ItemSortButton extends river.ConsumerWidget {
  const ItemSortButton({super.key});

  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    var currentOption = ref.watch(itemsCurrentSortNotifierProvider);
    var change = ref.read(itemsCurrentSortNotifierProvider.notifier).set;
    return _btnChangeSortOrder(currentOption, change);
  }

  Widget _btnChangeSortOrder(
    ItemSortingOption currentOption,
    Function(ItemSortingOption) change,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: PopupMenuButton(
        itemBuilder: (ctx) =>
            itemSortingOptions.map((o) => _createOption(o, change)).toList(),
        child: Row(
          children: [
            const Icon(Icons.sort),
            Icon(_arrowIcon(currentOption.asc)),
            Text(currentOption.displayName),
          ],
        ),
      ),
    );
  }

  IconData _arrowIcon(bool asc) =>
      asc ? Icons.arrow_upward : Icons.arrow_downward;

  PopupMenuEntry _createOption(
    ItemSortingOption so,
    Function(ItemSortingOption) change,
  ) => PopupMenuItem(
    value: so,
    onTap: () => change(so),
    child: Text(so.displayName),
  );
}
