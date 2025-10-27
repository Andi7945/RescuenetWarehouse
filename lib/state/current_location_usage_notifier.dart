import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';

import "package:collection/collection.dart";
import 'all_containers_notifier.dart';

part 'current_location_usage_notifier.g.dart';

@riverpod
class CurrentLocationUsageNotifier extends _$CurrentLocationUsageNotifier {
  @override
  AsyncValue<Map<CurrentLocation, Set<String>>> build() {
    var containersAsync = ref.watch(allContainersAsyncProvider);
    var dests = ref.watch(currentLocationsNotifierProvider);

    return containersAsync.when(
      data: (containers) {
        Map<CurrentLocation, Set<String>> grouped = containers
            .where((element) => element.type != null)
            .groupBy((p0) => p0.currentLocation!)
            .mapValues(
              (value) => value.map((e) => e.printName).whereNotNull().toSet(),
            );

        Map<CurrentLocation, Set<String>> map = {
          for (var e in dests) e: grouped[e] ?? Set(),
        };
        return AsyncValue.data(map);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }
}
