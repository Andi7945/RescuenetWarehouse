import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';

part 'container_by_id_notifier.g.dart';

/// Watches a single container by ID.
/// Only rebuilds when THIS specific container changes.
///
/// Returns RescueContainer (expanded with type, location, destination).
///
/// Usage:
/// ```dart
/// final container = ref.watch(containerByIdProvider(containerId));
/// ```
@riverpod
class ContainerById extends _$ContainerById {
  @override
  Stream<RescueContainer?> build(String containerId) {
    final repository = ref.watch(containerRepositoryProvider);
    final containerTypesNotifier = ref.watch(containerTypesNotifierProvider.notifier);
    final moduleDestinationsNotifier = ref.watch(moduleDestinationsNotifierProvider.notifier);
    final currentLocationsNotifier = ref.watch(currentLocationsNotifierProvider.notifier);

    return repository.watchContainer(containerId).map((dao) {
      if (dao == null) return null;

      final type = containerTypesNotifier.find(dao.typeId);
      final dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
      final loc = currentLocationsNotifier.find(dao.currentLocationId);

      return RescueContainer.fromDao(dao, type, dest, loc);
    });
  }
}
