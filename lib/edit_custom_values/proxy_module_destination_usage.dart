import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_module_destination.dart';

import "package:collection/collection.dart";

import '../store.dart';

ProxyProvider2 proxyModuleDestinationUsage() =>
    ProxyProvider2<Store, StoreModuleDestination, ModuleDestinationWithUsage>(
        update: (BuildContext context, Store store,
            StoreModuleDestination storeModuleDestination, previous) {
      Map<String, Set<String>> grouped = store.containerValues
          .where((element) => element.moduleDestination != null)
          .groupBy((p0) => p0.moduleDestination!)
          .mapValues(
              (value) => value.map((e) => e.name).whereNotNull().toSet());

      Map<String, Set<String>> map = {
        for (var e in storeModuleDestination.moduleDestinations)
          e: grouped[e] ?? Set()
      };

      return ModuleDestinationWithUsage(map);
    });

class ModuleDestinationWithUsage {
  final Map<String, Set<String>> destinationWithUsage;

  ModuleDestinationWithUsage(this.destinationWithUsage);
}