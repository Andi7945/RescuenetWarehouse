import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_state.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';
import 'package:rescuenet_warehouse/widgets/loading/data_loading_indicator.dart';
import 'package:rescuenet_warehouse/widgets/loading/error_retry_widget.dart';

import '../../../models/assignment.dart';
import 'assignment_by_container_single_item.dart';

class AssignmentByContainerItems extends ConsumerWidget {
  final RescueContainer container;

  AssignmentByContainerItems(this.container);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueBuilder<Map<Item, Assignment>>(
      value: ref.watch(assignmentByContainerAsyncProvider(container.id)),
      loading: () => const DataLoadingIndicator(
        message: 'Loading container assignments...',
      ),
      error: (error, stackTrace) => ErrorRetryWidget(
        error: error,
        message: 'Failed to load container assignments',
        onRetry: () =>
            ref.refresh(assignmentByContainerAsyncProvider(container.id)),
      ),
      data: (assignedItems) => _buildAssignmentsList(assignedItems),
    );
  }

  Widget _buildAssignmentsList(Map<Item, Assignment> assignedItems) {
    if (assignedItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No items assigned to this container',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Add items using the + button below',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

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
