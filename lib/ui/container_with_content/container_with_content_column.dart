import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/assignments_by_container_notifier.dart';
import 'package:rescuenet_warehouse/state/items_for_container_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_card.dart';
import 'package:rescuenet_warehouse/widgets/loading/data_loading_indicator.dart';
import 'package:rescuenet_warehouse/widgets/loading/error_retry_widget.dart';

import '../../models/item.dart';
import '../../models/assignment.dart';
import '../../models/rescue_container.dart';
import 'container_with_content_header.dart';

class ContainerWithContentColumn extends ConsumerWidget {
  final RescueContainer _container;

  ContainerWithContentColumn(this._container);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both assignments and items for this container
    // Both providers take containerId (String) - no list equality issues
    final assignmentsAsync = ref.watch(
      assignmentsByContainerProvider(_container.id),
    );
    final itemsAsync = ref.watch(
      itemsForContainerProvider(_container.id),
    );

    // Show loading if either is loading
    if (assignmentsAsync.isLoading || itemsAsync.isLoading) {
      return const DataLoadingIndicator(message: 'Loading container items...');
    }

    // Show error if either has error (prioritize assignments error)
    final error = assignmentsAsync.error ?? itemsAsync.error;
    if (error != null) {
      return ErrorRetryWidget(
        error: error,
        message: 'Failed to load container data',
        onRetry: () {
          ref.refresh(assignmentsByContainerProvider(_container.id));
          ref.refresh(itemsForContainerProvider(_container.id));
        },
      );
    }

    // Both have data - build content
    final assignments = assignmentsAsync.valueOrNull ?? [];
    final items = itemsAsync.valueOrNull ?? [];

    return _buildContainerContent(assignments, items);
  }

  Widget _buildContainerContent(
    List<Assignment> containerAssignments,
    List<Item> filteredItems,
  ) {
    // containerAssignments already filtered by family provider
    // filteredItems already filtered to only items in this container's assignments

    // Create a map of items to their assignment counts for this container
    var items = <Item, int>{};

    // Create a lookup map for O(1) access
    var itemsById = {for (var item in filteredItems) item.id: item};

    for (var assignment in containerAssignments) {
      if (assignment.count > 0) {
        var item = itemsById[assignment.itemId];
        if (item != null) {
          items[item] = assignment.count;
        }
      }
    }

    if (items.isEmpty) {
      return ListView(
        shrinkWrap: true,
        children: [
          ContainerWithContentHeader(_container, items),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No items assigned to this container',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        ContainerWithContentHeader(_container, items),
        ..._sortedEntries(items).map((e) => ItemCard(e.key, e.value, true)),
      ],
    );
  }

  List<MapEntry<Item, int>> _sortedEntries(Map<Item, int> items) {
    var entries = items.entries.toList();
    entries.sort((a, b) => (a.key.name ?? "").compareTo(b.key.name ?? ""));
    return entries;
  }
}
