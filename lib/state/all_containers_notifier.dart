import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

import '../models/container_dao.dart';
import '../models/rescue_container.dart';
import '../models/sequential_build.dart';

part 'all_containers_notifier.g.dart';

/// Stream-based provider for backward compatibility.
/// This maintains the existing Stream&lt;List&lt;RescueContainer&gt;&gt; pattern that other
/// parts of the app may depend on.
@riverpod
Stream<List<RescueContainer>> allContainersStream(Ref ref) {
  final repository = ref.watch(containerRepositoryProvider);
  final containerTypesNotifier = ref.watch(
    containerTypesNotifierProvider.notifier,
  );
  final moduleDestinationsNotifier = ref.watch(
    moduleDestinationsNotifierProvider.notifier,
  );
  final currentLocationsNotifier = ref.watch(
    currentLocationsNotifierProvider.notifier,
  );

  return repository.watchContainers().map((containers) {
    return containers.map((dao) {
      var type = containerTypesNotifier.find(dao.typeId);
      var dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
      var loc = currentLocationsNotifier.find(dao.currentLocationId);
      return RescueContainer.fromDao(dao, type, dest, loc);
    }).toList();
  });
}

/// AsyncValue-based containers provider for loading states support.
///
/// This provider wraps the containers stream in AsyncValue to provide proper
/// loading, error, and data states for UI components. It follows the enhanced
/// pattern from LOADING_INDICATORS_DESIGN.md while maintaining compatibility
/// with the existing AllContainersNotifier.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<RescueContainer>>(
///   value: ref.watch(allContainersAsyncProvider),
///   data: (containers) => ContainerGrid(containers: containers),
/// )
/// ```
@riverpod
class AllContainersAsync extends _$AllContainersAsync {
  @override
  Stream<List<RescueContainer>> build() {
    final repository = ref.watch(containerRepositoryProvider);
    final containerTypesNotifier = ref.watch(
      containerTypesNotifierProvider.notifier,
    );
    final moduleDestinationsNotifier = ref.watch(
      moduleDestinationsNotifierProvider.notifier,
    );
    final currentLocationsNotifier = ref.watch(
      currentLocationsNotifierProvider.notifier,
    );

    return repository.watchContainers().map((containers) {
      return containers.map((dao) {
        var type = containerTypesNotifier.find(dao.typeId);
        var dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
        var loc = currentLocationsNotifier.find(dao.currentLocationId);
        return RescueContainer.fromDao(dao, type, dest, loc);
      }).toList();
    });
  }

  /// Get container by ID from the current async state
  RescueContainer? byId(String id) {
    return state.valueOrNull?.firstWhereOrNull((element) => element.id == id);
  }

  /// Get containers by IDs from the current async state
  List<RescueContainer> byIds(List<String> ids) {
    final containers = state.valueOrNull;
    if (containers == null) return [];
    return containers.where((container) => ids.contains(container.id)).toList();
  }

  /// Create a new container using the async state for number generation
  RescueContainer newContainer() {
    final currentContainers = state.valueOrNull ?? [];
    var containerNumbers = currentContainers.map((c) => c.number).toList();
    containerNumbers.sort();

    var value = 1;
    for (int curr in containerNumbers) {
      if (curr != value) {
        break;
      }
      value = curr + 1;
    }

    var newContainer = ContainerDao(
      id: uuid.v4(),
      number: value,
      name: "",
      sequentialBuild: SequentialBuild.firstBuild,
      isReady: false,
      toDeploy: false,
    );
    ref.read(containerRepositoryProvider).createContainer(newContainer);

    // Expand the container using the same logic as the main notifier
    var type = ref
        .watch(containerTypesNotifierProvider.notifier)
        .find(newContainer.typeId);
    var dest = ref
        .watch(moduleDestinationsNotifierProvider.notifier)
        .find(newContainer.moduleDestinationId);
    var loc = ref
        .watch(currentLocationsNotifierProvider.notifier)
        .find(newContainer.currentLocationId);

    return RescueContainer.fromDao(newContainer, type, dest, loc);
  }

  /// Update a container
  Future<void> updateContainer(RescueContainer container) async {
    await ref
        .read(containerRepositoryProvider)
        .updateContainer(ContainerDao.fromContainer(container));
  }

  /// Delete a container
  Future<void> deleteContainer(RescueContainer container) async {
    await ref.read(containerRepositoryProvider).deleteContainer(container.id);
  }

  /// Refresh the containers data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
