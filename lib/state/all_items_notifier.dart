import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

import '../models/item.dart';

part 'all_items_notifier.g.dart';

@riverpod
class AllItemsNotifier extends _$AllItemsNotifier {
  @override
  List<Item> build() {
    final repository = ref.watch(itemRepositoryProvider);

    // Use ref.listen to properly manage the stream subscription
    final subscription = repository.watchItems().listen((items) {
      state = items;
    });

    // Dispose subscription when notifier is disposed
    ref.onDispose(() {
      subscription.cancel();
    });

    return [];
  }

  Item? byId(String id) {
    return state.firstWhereOrNull((element) => element.id == id);
  }

  List<Item> byIds(List<String> ids) {
    return state.where((itm) => ids.contains(itm.id)).toList();
  }
}

/// Stream-based provider for backward compatibility.
/// This maintains the existing Stream<List<Item>> pattern that other
/// parts of the app may depend on.
@riverpod
Stream<List<Item>> allItemsStream(AllItemsStreamRef ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchItems();
}

/// AsyncValue-based items provider for loading states support.
///
/// This provider wraps the items stream in AsyncValue to provide proper
/// loading, error, and data states for UI components. It follows the enhanced
/// pattern from LOADING_INDICATORS_DESIGN.md while maintaining compatibility
/// with the existing AllItemsNotifier.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<Item>>(
///   value: ref.watch(allItemsAsyncProvider),
///   data: (items) => ItemGrid(items: items),
/// )
/// ```
@riverpod
class AllItemsAsync extends _$AllItemsAsync {
  @override
  Stream<List<Item>> build() {
    final repository = ref.watch(itemRepositoryProvider);
    return repository.watchItems();
  }

  /// Get item by ID from the current async state
  Item? byId(String id) {
    return state.valueOrNull?.firstWhereOrNull((element) => element.id == id);
  }

  /// Get items by IDs from the current async state
  List<Item> byIds(List<String> ids) {
    final items = state.valueOrNull;
    if (items == null) return [];
    return items.where((itm) => ids.contains(itm.id)).toList();
  }

  /// Refresh the items data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
