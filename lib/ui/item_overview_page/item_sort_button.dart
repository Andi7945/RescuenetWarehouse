import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/models/item_sorting_options.dart';
import 'package:rescuenet_warehouse/services/item_sort_service.dart';

class ItemSortButton extends StatelessWidget {
  const ItemSortButton({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ItemSortService>(
      builder: (_, service, __) => _btnChangeSortOrder(service));

  Widget _btnChangeSortOrder(ItemSortService service) {
    return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: PopupMenuButton(
            itemBuilder: (ctx) => itemSortingOptions
                .map((o) => _createOption(o, service))
                .toList(),
            child: Row(children: [
              const Icon(Icons.sort),
              Icon(_icon(service)),
              Text(service.sortedBy.displayName),
            ])));
  }

  IconData _icon(ItemSortService service) =>
      service.sortedAsc ? Icons.arrow_upward : Icons.arrow_downward;

  PopupMenuEntry _createOption(ItemSortingOption so, ItemSortService service) =>
      PopupMenuItem(
          value: so,
          onTap: () => service.setOption(so),
          child: Text(so.displayName));
}
