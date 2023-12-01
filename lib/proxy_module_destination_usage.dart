import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/services/container_service.dart';

import "package:collection/collection.dart";
import 'package:rescuenet_warehouse/models/module_destination.dart';

import 'stores.dart';

ProxyProvider2 proxyModuleDestinationUsage() => ProxyProvider2<ContainerService,
            StoreModuleDestination, ModuleDestinationWithUsage>(
        update: (BuildContext context, ContainerService service,
            StoreModuleDestination storeModuleDestination, previous) {
      Map<ModuleDestination, Set<String>> grouped = service.containerValues
          .where((element) => element.moduleDestination != null)
          .groupBy((p0) => p0.moduleDestination!)
          .mapValues(
              (value) => value.map((e) => e.printName).whereNotNull().toSet());

      Map<ModuleDestination, Set<String>> map = {
        for (var e in storeModuleDestination.all)
          e: grouped[e] ?? Set()
      };

      return ModuleDestinationWithUsage(map);
    });

class ModuleDestinationWithUsage {
  final Map<ModuleDestination, Set<String>> destinationWithUsage;

  ModuleDestinationWithUsage(this.destinationWithUsage);
}
