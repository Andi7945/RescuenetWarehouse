import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';

part 'containers_by_ready_status_notifier.g.dart';

/// Watches containers by ready status.
/// Only rebuilds when containers with THIS status change.
///
/// Usage:
/// ```dart
/// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
/// ```
@riverpod
class ContainersByReadyStatus extends _$ContainersByReadyStatus {
  @override
  Stream<List<RescueContainer>> build(bool isReady) {
    final repository = ref.watch(containerRepositoryProvider);
    final containerTypesNotifier = ref.watch(containerTypesNotifierProvider.notifier);
    final moduleDestinationsNotifier = ref.watch(moduleDestinationsNotifierProvider.notifier);
    final currentLocationsNotifier = ref.watch(currentLocationsNotifierProvider.notifier);

    return repository.watchContainersByReadyStatus(isReady).map((containers) {
      return containers.map((dao) {
        final type = containerTypesNotifier.find(dao.typeId);
        final dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
        final loc = currentLocationsNotifier.find(dao.currentLocationId);
        return RescueContainer.fromDao(dao, type, dest, loc);
      }).toList();
    });
  }
}
