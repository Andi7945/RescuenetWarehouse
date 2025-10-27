import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/item.dart';
import '../models/assignment.dart';

part 'assignable_items_notifier.g.dart';

/// AsyncValue-based assignable items provider for loading states support.
///
/// This provider wraps both items and assignments in AsyncValue to provide proper
/// loading, error, and data states for UI components. It calculates assignable item
/// quantities based on existing assignments while supporting loading states.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<Map<Item, int>>(
///   value: ref.watch(assignableItemsAsyncProvider),
///   data: (assignableItems) => AssignableItemsList(assignableItems: assignableItems),
/// )
/// ```
@riverpod
class AssignableItemsAsync extends _$AssignableItemsAsync {
  @override
  Stream<Map<Item, int>> build() {
    // Watch both items and assignments as streams
    final itemsStream = ref.watch(allItemsAsyncProvider.future);
    final assignmentsStream = ref.watch(allAssignmentsAsyncProvider.future);

    return Stream.fromFuture(
      Future.wait([itemsStream, assignmentsStream]).then((results) {
        final items = results[0] as List<Item>;
        final assignments = results[1] as List<Assignment>;

        var alreadyAssigned = assignments
            .groupBy((a) => a.itemId)
            .mapValues((a) => a.fold(0, (p, e) => p + e.count));

        return Map.fromEntries(
          items.map((i) {
            if (alreadyAssigned[i.id] == null ||
                i.totalAmount > (alreadyAssigned[i.id] ?? 0)) {
              return MapEntry(i, i.totalAmount - (alreadyAssigned[i.id] ?? 0));
            }
            return null; // Filter out items with no assignable quantity
          }).nonNulls,
        );
      }),
    );
  }

  /// Refresh the assignable items data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
