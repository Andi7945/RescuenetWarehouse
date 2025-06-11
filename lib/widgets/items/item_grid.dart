import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/widgets/items/selectable_item_card.dart';

import '../../models/item.dart';

class ItemGrid extends StatelessWidget {
  final List<Item> items;
  final void Function(Item) onSelect;
  final bool Function(Item) isSelected;

  const ItemGrid({
    super.key,
    required this.items,
    required this.onSelect,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) => _content();

  _content() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: items.map(_card).toList(),
        ),
      ),
    );
  }

  Widget _card(Item i) => SelectableItemCard(
    item: i,
    amount: i.totalAmount,
    onTap: () => onSelect(i),
    isSelected: isSelected(i),
  );
}
