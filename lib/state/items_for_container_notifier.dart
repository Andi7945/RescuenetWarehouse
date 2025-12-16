import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'items_for_container_notifier.g.dart';

/// Watches items assigned to a specific container.
///
/// Automatically updates when:
/// - Assignments for this container change
/// - Items in this container change
///
/// This provider solves the infinite loading issue by using containerId
/// (String with value equality) instead of List<String> as the family parameter.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsForContainerProvider(containerId));
/// ```
@riverpod
class ItemsForContainer extends _$ItemsForContainer {
  @override
  Stream<List<Item>> build(String containerId) {
    // Get repositories
    final assignmentRepository = ref.watch(assignmentRepositoryProvider);
    final itemRepository = ref.watch(itemRepositoryProvider);

    // Watch assignments stream for this container
    final assignmentsStream = assignmentRepository.watchAssignmentsByContainer(containerId);

    // When assignments change, switch to watching the new set of items
    return assignmentsStream.switchMap((assignments) {
      // Extract item IDs from assignments (pure function - no side effects)
      final itemIds = assignments
          .where((a) => a.count > 0)
          .map((a) => a.itemId)
          .toList();

      // Handle empty case early
      if (itemIds.isEmpty) {
        return Stream.value(<Item>[]);
      }

      // Watch items for these IDs
      // When assignments change, switchMap cancels the old stream
      // and switches to the new items stream
      return itemRepository.watchItemsByIds(itemIds);
    });
  }
}
