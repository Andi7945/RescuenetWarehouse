import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_options.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_module_destination.dart';

import 'store.dart';

ProxyProvider2 proxyContainerOptions() =>
    ProxyProvider2<Store, StoreModuleDestination, ContainerOptions>(
        update: (ctx, Store store,
                StoreModuleDestination storeModuleDestination, prev) =>
            ContainerOptions(
                store.containerTypes,
                storeModuleDestination.moduleDestinations,
                store.currentLocations));
