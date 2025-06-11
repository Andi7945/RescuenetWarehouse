import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/ui/rescue_image.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../models/item.dart';
import 'sign_row.dart';

class ItemCardBase extends ConsumerWidget {
  final Item _item;
  final int _amount;
  static const double cardWidth = 370;
  final bool _sumWeight;

  ItemCardBase(this._item, this._amount, this._sumWeight);

  DateTime? _nextExpiringDate() {
    if (_item.expiringDates.isEmpty) {
      return null;
    }
    var dates = List.from(_item.expiringDates);
    dates.sort();
    return dates.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => _card();

  _card() => Container(
    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
    decoration: const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RescueImage(_item.imagePath, 90),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: cardWidth - 90,
              child: RescueText.normal(_item.name ?? ""),
            ),
            Container(
              width: cardWidth - 90,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [amountWithLabel(), weightWithLabel()],
              ),
            ),
            SignRow(
              _item.signs,
              _nextExpiringDate(),
              _item.operationalStatus,
              _item.isColdChain,
            ),
          ],
        ),
      ],
    ),
  );

  Column weightWithLabel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RescueText.slim(_weightLabel()),
        const SizedBox(height: 4),
        RescueText.normal('${_weight()} kg'),
      ],
    );
  }

  _weightLabel() => _sumWeight ? "Sum Weight" : "Weight per unit";

  _weightAmount() => _sumWeight ? _item.weight * _amount : _item.weight;

  _weight() => double.parse(_weightAmount().toStringAsFixed(2));

  Column amountWithLabel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RescueText.slim('Amount'),
        const SizedBox(height: 4),
        RescueText.normal('$_amount x'),
      ],
    );
  }
}
