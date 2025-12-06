import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/assignments_by_container_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_card.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';
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
    return AsyncValueBuilder<List<Assignment>>(
      value: ref.watch(assignmentsByContainerProvider(_container.id)),
      loading: () => const DataLoadingIndicator(
        message: 'Loading container assignments...',
      ),
      error: (error, stackTrace) => ErrorRetryWidget(
        error: error,
        message: 'Failed to load container assignments',
        onRetry: () => ref.refresh(assignmentsByContainerProvider(_container.id)),
      ),
      data: (containerAssignments) => AsyncValueBuilder<List<Item>>(
        value: ref.watch(allItemsAsyncProvider),
        loading: () => const DataLoadingIndicator(message: 'Loading items...'),
        error: (error, stackTrace) => ErrorRetryWidget(
          error: error,
          message: 'Failed to load items',
          onRetry: () => ref.refresh(allItemsAsyncProvider),
        ),
        data: (allItems) => _buildContainerContent(containerAssignments, allItems),
      ),
    );
  }

  Widget _buildContainerContent(
    List<Assignment> containerAssignments,
    List<Item> allItems,
  ) {
    // containerAssignments already filtered by family provider

    // Create a map of items to their assignment counts for this container
    var items = <Item, int>{};
    for (var assignment in containerAssignments) {
      if (assignment.count > 0) {
        try {
          var item = allItems.firstWhere((i) => i.id == assignment.itemId);
          items[item] = assignment.count;
        } catch (e) {
          // Item not found - skip this assignment (this should not happen in normal operation)
          // Using debugPrint to avoid production warnings
          // debugPrint('Warning: Item with ID ${assignment.itemId} not found for container ${_container.id}');
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
