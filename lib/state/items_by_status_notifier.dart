import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

part 'items_by_status_notifier.g.dart';

/// Watches items with a specific operational status.
/// Only rebuilds when items with THIS status change.
///
/// Usage:
/// ```dart
/// final deployableItems = ref.watch(
///   itemsByStatusProvider(OperationalStatus.deployable),
/// );
/// ```
@riverpod
class ItemsByStatus extends _$ItemsByStatus {
  @override
  Stream<List<Item>> build(OperationalStatus status) {
    final repository = ref.watch(itemRepositoryProvider);
    return repository.watchItemsByStatus(status);
  }

  /// Get count of items with this status
  int get count => state.valueOrNull?.length ?? 0;
}
