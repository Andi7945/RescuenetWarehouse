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
  AsyncValue<Map<ContainerType, Set<String>>> build() {
    var containersAsync = ref.watch(allContainersAsyncProvider);
    var types = ref.watch(containerTypesNotifierProvider);

    return containersAsync.when(
      data: (containers) {
        Map<ContainerType, Set<String>> grouped = containers
            .where((element) => element.type != null)
            .groupBy((p0) => p0.type!)
            .mapValues(
              (value) => value.map((e) => e.printName).whereNotNull().toSet(),
            );

        Map<ContainerType, Set<String>> map = {
          for (var e in types) e: grouped[e] ?? Set(),
        };
        return AsyncValue.data(map);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }
}
