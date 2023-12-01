import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/stores.dart';

import "package:collection/collection.dart";

import '../container_service.dart';
import '../models/container_type.dart';

ProxyProvider2 proxyContainerTypeUsage() {
  return ProxyProvider2<ContainerService, StoreContainerTypes,
      ContainerTypeUsage>(update: (ctx, service, store, prev) {
    Map<ContainerType, Set<String>> grouped = service.containerValues
        .where((element) => element.type != null)
        .groupBy((p0) => p0.type!)
        .mapValues(
            (value) => value.map((e) => e.printName).whereNotNull().toSet());

    Map<ContainerType, Set<String>> map = {
      for (var e in store.all) e: grouped[e] ?? Set()
    };

    return ContainerTypeUsage(map);
  });
}

class ContainerTypeUsage {
  final Map<ContainerType, Set<String>> typesWithUsages;

  ContainerTypeUsage(this.typesWithUsages);
}
