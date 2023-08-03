import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_options.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_container_types.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_current_locations.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_module_destination.dart';

ProxyProvider3 proxyContainerOptions() => ProxyProvider3<StoreContainerTypes,
        StoreCurrentLocations, StoreModuleDestination, ContainerOptions>(
    update: (ctx,
            StoreContainerTypes storeContainerTypes,
            StoreCurrentLocations storeCurrentLocations,
            StoreModuleDestination storeModuleDestination,
            prev) =>
        ContainerOptions(
            storeContainerTypes.containerTypes,
            storeModuleDestination.moduleDestinations,
            storeCurrentLocations.currentLocations));
