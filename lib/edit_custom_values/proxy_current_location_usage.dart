import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_current_locations.dart';

import "package:collection/collection.dart";

import '../store.dart';

ProxyProvider2 proxyCurrentLocationUsage() =>
    ProxyProvider2<Store, StoreCurrentLocations, CurrentLocationsWithUsage>(
        update: (BuildContext context, Store store,
            StoreCurrentLocations storeCurrentLocations, previous) {
      Map<String, Set<String>> grouped = store.containers
          .where((element) => element.currentLocation != null)
          .groupBy((p0) => p0.currentLocation!)
          .mapValues(
              (value) => value.map((e) => e.name).whereNotNull().toSet());

      Map<String, Set<String>> map = {
        for (var e in storeCurrentLocations.currentLocations)
          e: grouped[e] ?? Set()
      };

      return CurrentLocationsWithUsage(map);
    });

class CurrentLocationsWithUsage {
  final Map<String, Set<String>> currentLocationsWithUsage;

  CurrentLocationsWithUsage(this.currentLocationsWithUsage);
}
