import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/ui/item_card.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../../models/assignment.dart';

class AssignmentByContainerSingleItem extends ConsumerWidget {
  final Item _item;
  final Assignment _assignment;

  AssignmentByContainerSingleItem(this._item, this._assignment);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(children: [_itemCard(), _assignArea(ref)]);
  }

  _itemCard() {
    return Expanded(child: ItemCard(_item, _assignment.count, false));
  }

  _assignArea(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        spacing: 8.0,
        children: [
          RescueText(56, '${_assignment.count}x'),
          Container(width: 8),
          _iconButton(ref, _assignment.count - 1, Icons.exposure_minus_1),
          _iconButton(ref, _assignment.count + 1, Icons.plus_one),
        ],
      ),
    );
  }

  _iconButton(ref, int newCount, IconData icon) => IconButton(
    iconSize: 56,
    onPressed: () {
      final repository = ref.read(assignmentRepositoryProvider);
      final updatedAssignment = _assignment.copyWith(count: newCount);
      repository.upsertOrDeleteAssignment(updatedAssignment);
    },
    style: IconButton.styleFrom(backgroundColor: Colors.blue),
    color: Colors.white,
    icon: Icon(icon),
  );
}
