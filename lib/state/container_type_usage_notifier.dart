import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';

import "package:collection/collection.dart";
import '../models/container_type.dart';
import 'all_containers_notifier.dart';

part 'container_type_usage_notifier.g.dart';

@riverpod
class ContainerTypeUsageNotifier extends _$ContainerTypeUsageNotifier {
  @override
  Map<ContainerType, Set<String>> build() {
    var containers = ref.watch(allContainersNotifierProvider);
    var types = ref.watch(containerTypesNotifierProvider);

    Map<ContainerType, Set<String>> grouped = containers
        .where((element) => element.type != null)
        .groupBy((p0) => p0.type!)
        .mapValues(
            (value) => value.map((e) => e.printName).whereNotNull().toSet());

    Map<ContainerType, Set<String>> map = {
      for (var e in types) e: grouped[e] ?? Set()
    };
    return map;
  }
}
