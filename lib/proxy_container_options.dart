import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/models/container_options.dart';
import 'package:rescuenet_warehouse/stores.dart';

ProxyProvider3 proxyContainerOptions() => ProxyProvider3<StoreContainerTypes,
        StoreCurrentLocations, StoreModuleDestination, ContainerOptions>(
    update: (ctx,
            StoreContainerTypes storeContainerTypes,
            StoreCurrentLocations storeCurrentLocations,
            StoreModuleDestination storeModuleDestination,
            prev) =>
        ContainerOptions(storeContainerTypes.all, storeModuleDestination.all,
            storeCurrentLocations.all));
