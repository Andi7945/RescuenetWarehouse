import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/services/item_filter_service.dart';
import 'package:rescuenet_warehouse/ui/item_overview_page/item_filter_modal.dart';

class ItemChooserAction extends StatelessWidget {
  const ItemChooserAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemFilterService>(
        builder: (ctx, filterService, _) => ActionChip(
            label: Row(children: [
              Text(
                  "${filterService.filteredItemsSize} / ${filterService.unfilteredItemsSize}"),
              const Icon(Icons.filter_alt, color: Colors.blue)
            ]),
            onPressed: () {
              showDialog(context: context, builder: (ctx) => ItemFilterModal());
            }));
  }
}
