import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

import '../models/container_dao.dart';
import '../models/rescue_container.dart';
import '../models/sequential_build.dart';

part 'all_containers_notifier.g.dart';

@riverpod
class AllContainersNotifier extends _$AllContainersNotifier {
  @override
  List<RescueContainer> build() {
    final repository = ref.watch(containerRepositoryProvider);
    
    // Subscribe to the stream and update state when data changes
    repository.watchContainers().listen((containers) {
      if (mounted) {
        state = containers.map(_expand).toList();
      }
    });
    
    return [];
  }

  RescueContainer _expand(ContainerDao dao) {
    var type = ref
        .watch(containerTypesNotifierProvider.notifier)
        .find(dao.typeId);
    var dest = ref
        .watch(moduleDestinationsNotifierProvider.notifier)
        .find(dao.moduleDestinationId);
    var loc = ref
        .watch(currentLocationsNotifierProvider.notifier)
        .find(dao.currentLocationId);

    return RescueContainer.fromDao(dao, type, dest, loc);
  }

  RescueContainer? byId(String id) {
    return state.firstWhereOrNull((element) => element.id == id);
  }

  RescueContainer newContainer() {
    var newContainer = ContainerDao(
      id: uuid.v4(),
      number: _firstUnusedNumber(),
      name: "",
      sequentialBuild: SequentialBuild.firstBuild,
      isReady: false,
      toDeploy: false,
    );
    ref.read(containerRepositoryProvider).createContainer(newContainer);
    return _expand(newContainer);
  }

  int _firstUnusedNumber() {
    var containerNumbers = state.map((c) => c.number).toList();
    containerNumbers.sort();

    var value = 1;
    for (int curr in containerNumbers) {
      if (curr != value) {
        break;
      }
      value = curr + 1;
    }
    return value;
  }

  update(RescueContainer container) => ref
      .read(containerRepositoryProvider)
      .updateContainer(ContainerDao.fromContainer(container));

  delete(RescueContainer container) =>
      ref.read(containerRepositoryProvider).deleteContainer(container.id);
}
