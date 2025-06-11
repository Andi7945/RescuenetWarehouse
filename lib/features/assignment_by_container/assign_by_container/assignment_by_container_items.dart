import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_state.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import '../../../models/assignment.dart';
import 'assignment_by_container_single_item.dart';

class AssignmentByContainerItems extends ConsumerWidget {
  final RescueContainer container;

  AssignmentByContainerItems(this.container);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var assignedItems = ref.watch(
      assignmentByContainerStateProvider(container.id),
    );
    return ListView(
      shrinkWrap: true,
      children: [
        ..._sortedEntries(
          assignedItems,
        ).map((e) => AssignmentByContainerSingleItem(e.key, e.value)),
      ],
    );
  }

  List<MapEntry<Item, Assignment>> _sortedEntries(Map<Item, Assignment> items) {
    var entries = items.entries.toList();
    entries.sort((a, b) => (a.key.name ?? "").compareTo(b.key.name ?? ""));
    return entries;
  }
}
