import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'item_by_id_notifier.g.dart';

/// Watches a single item by ID.
/// Only rebuilds when THIS specific item changes.
///
/// Usage:
/// ```dart
/// final item = ref.watch(itemByIdProvider(itemId));
/// ```
@riverpod
class ItemById extends _$ItemById {
  @override
  Stream<Item?> build(String itemId) {
    final repository = ref.watch(itemRepositoryProvider);
    return repository.watchItem(itemId);
  }

  /// Convenience method to get item from current state
  Item? get item => state.valueOrNull;

  /// Check if item is deployable
  bool get isDeployable =>
      item?.operationalStatus == OperationalStatus.deployable;
}
