import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';

import "package:collection/collection.dart";
import 'all_containers_notifier.dart';

part 'module_destination_usage_notifier.g.dart';

@riverpod
class ModuleDestinationUsageNotifier extends _$ModuleDestinationUsageNotifier {
  @override
  Map<ModuleDestination, Set<String>> build() {
    var containers = ref.watch(allContainersNotifierProvider);
    var dests = ref.watch(moduleDestinationsNotifierProvider);

    Map<ModuleDestination, Set<String>> grouped = containers
        .where((element) => element.type != null)
        .groupBy((p0) => p0.moduleDestination!)
        .mapValues(
            (value) => value.map((e) => e.printName).whereNotNull().toSet());

    Map<ModuleDestination, Set<String>> map = {
      for (var e in dests) e: grouped[e] ?? Set()
    };
    return map;
  }
}
