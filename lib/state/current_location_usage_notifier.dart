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
  Map<CurrentLocation, Set<String>> build() {
    var containers = ref.watch(allContainersNotifierProvider);
    var dests = ref.watch(currentLocationsNotifierProvider);

    Map<CurrentLocation, Set<String>> grouped = containers
        .where((element) => element.type != null)
        .groupBy((p0) => p0.currentLocation!)
        .mapValues(
            (value) => value.map((e) => e.printName).whereNotNull().toSet());

    Map<CurrentLocation, Set<String>> map = {
      for (var e in dests) e: grouped[e] ?? Set()
    };
    return map;
  }
}
