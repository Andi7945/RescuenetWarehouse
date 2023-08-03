import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_options.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_current_locations.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_module_destination.dart';

import 'store.dart';

ProxyProvider3 proxyContainerOptions() => ProxyProvider3<Store,
        StoreCurrentLocations, StoreModuleDestination, ContainerOptions>(
    update: (ctx, Store store, StoreCurrentLocations storeCurrentLocations,
            StoreModuleDestination storeModuleDestination, prev) =>
        ContainerOptions(
            store.containerTypes,
            storeModuleDestination.moduleDestinations,
            storeCurrentLocations.currentLocations));
