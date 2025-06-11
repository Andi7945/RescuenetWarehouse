import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/ui/item_card_base.dart';

import '../models/item.dart';
import '../state/current_item_notifier.dart';

class ItemCard extends ConsumerWidget {
  final Item _item;
  final int _amount;
  static const double cardWidth = 370;
  final bool _sumWeight;

  ItemCard(this._item, this._amount, this._sumWeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) => InkWell(
    onTap: _navigateToItemFn(context, ref),
    child: ItemCardBase(_item, _amount, _sumWeight),
  );

  _navigateToItemFn(BuildContext context, WidgetRef ref) => () {
    ref.watch(currentItemNotifierProvider.notifier).setItem(_item);
    Navigator.pushNamed(context, routeItemEditPage, arguments: _item.id);
  };
}
