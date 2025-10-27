import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/ui/item_card_base.dart';

class SelectableItemCard extends StatelessWidget {
  final Item item;
  final int amount;
  final Function() onTap;
  final bool isSelected;

  const SelectableItemCard({
    super.key,
    required this.item,
    required this.amount,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Stack(
      children: [ItemCardBase(item, amount, true), _selectedIndicator()],
    ),
  );

  Widget _selectedIndicator() => SizedBox(
    width: 370,
    child: isSelected
        ? Card(elevation: 12, child: Center(child: Text('Selected')))
        : Container(),
  );
}
