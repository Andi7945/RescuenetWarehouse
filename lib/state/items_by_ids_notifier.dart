import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'items_by_ids_notifier.g.dart';

/// Watches a subset of items by their IDs.
/// Only rebuilds when items in THIS subset change.
///
/// Useful for assignment views where you need multiple items
/// but not the entire collection.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsByIdsProvider(['id1', 'id2', 'id3']));
/// ```
@riverpod
class ItemsByIds extends _$ItemsByIds {
  @override
  Stream<List<Item>> build(List<String> itemIds) {
    final repository = ref.watch(itemRepositoryProvider);
    return repository.watchItemsByIds(itemIds);
  }
}
