import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_current_locations.dart';

import "package:collection/collection.dart";

ProxyProvider2 proxyCurrentLocationUsage() => ProxyProvider2<ContainerService,
            StoreCurrentLocations, CurrentLocationsWithUsage>(
        update: (BuildContext context, ContainerService service,
            StoreCurrentLocations storeCurrentLocations, previous) {
      Map<CurrentLocation, Set<String>> grouped = service.containerValues
          .where((element) => element.currentLocation != null)
          .groupBy((p0) => p0.currentLocation!)
          .mapValues(
              (value) => value.map((e) => e.name).whereNotNull().toSet());

      Map<CurrentLocation, Set<String>> map = {
        for (var e in storeCurrentLocations.currentLocations)
          e: grouped[e] ?? Set()
      };

      return CurrentLocationsWithUsage(map);
    });

class CurrentLocationsWithUsage {
  final Map<CurrentLocation, Set<String>> currentLocationsWithUsage;

  CurrentLocationsWithUsage(this.currentLocationsWithUsage);
}
