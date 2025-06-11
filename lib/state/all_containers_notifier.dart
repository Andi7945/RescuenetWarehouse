import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/main.dart';

import '../models/container_dao.dart';
import '../models/rescue_container.dart';
import '../models/sequential_build.dart';

import '../db/container_data.dart';

part 'all_containers_notifier.g.dart';

@riverpod
class AllContainersNotifier extends _$AllContainersNotifier {
  @override
  List<RescueContainer> build() {
    var data = ref.watch(containerDataProvider);
    return data.map(_expand).toList();
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
    ref.read(containerDataProvider.notifier).upsert(newContainer);
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
      .read(containerDataProvider.notifier)
      .upsert(ContainerDao.fromContainer(container));

  delete(RescueContainer container) =>
      ref.read(containerDataProvider.notifier).delete(container.id);
}
