import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/measurements.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/ui/rescue_image.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/ui/sign_row.dart';

import 'assignment_search_attribute.dart';

class AssignmentSearchItemCard extends ConsumerWidget {
  final Item item;
  final int amount;
  final Widget? sortingField;
  final Widget? filterField;
  static const double cardWidth = 370;

  AssignmentSearchItemCard({
    required this.item,
    required this.amount,
    this.sortingField,
    this.filterField,
  });

  DateTime? _nextExpiringDate() {
    if (item.expiringDates.isEmpty) {
      return null;
    }
    var dates = List.from(item.expiringDates);
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
        RescueImage(item.imagePath, 90),
        kHSpacer8,
        Expanded(child: itemFields()),
        kHSpacer8,
        SignRow(
          item.signs,
          _nextExpiringDate(),
          item.operationalStatus,
          item.isColdChain,
        ),
      ],
    ),
  );

  Column itemFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RescueText.normal(item.name ?? ""),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              amountWithLabel(),
              kHSpacer12,
              weightWithLabel(),
              filterField != null ? kHSpacer12 : Container(),
              filterField ?? Container(),
              sortingField != null ? kHSpacer12 : Container(),
              sortingField ?? Container(),
            ],
          ),
        ),
      ],
    );
  }

  Widget weightWithLabel() => AssignmentSearchAttribute(
    label: "Weight per unit",
    value: '${_weight()} kg',
  );

  _weight() => double.parse(item.weight.toStringAsFixed(2));

  Widget amountWithLabel() =>
      AssignmentSearchAttribute(label: 'Available Amount', value: '$amount x');
}
