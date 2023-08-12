import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_current_locations.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_module_destination.dart';

import 'container_dao.dart';
import 'edit_custom_values/store_container_types.dart';
import 'rescue_container.dart';

class ContainerMapperService {
  late StoreContainerTypes storeContainerTypes;
  late StoreModuleDestination storeModuleDestination;
  late StoreCurrentLocations storeCurrentLocations;

  setStores(
      StoreContainerTypes storeContainerTypes,
      StoreModuleDestination storeModuleDestination,
      StoreCurrentLocations storeCurrentLocations) {
    this.storeContainerTypes = storeContainerTypes;
    this.storeModuleDestination = storeModuleDestination;
    this.storeCurrentLocations = storeCurrentLocations;
  }

  RescueContainer fromDao(ContainerDao dao) => RescueContainer.fromDao(
      dao,
      storeContainerTypes.get(dao.typeId),
      storeModuleDestination.get(dao.moduleDestinationId),
      storeCurrentLocations.get(dao.currentLocationId));
}

ProxyProvider3 provideMapperService() => ProxyProvider3<StoreContainerTypes,
        StoreModuleDestination, StoreCurrentLocations, ContainerMapperService>(
    create: (ctx) => ContainerMapperService(),
    update: (ctx, storeContainerTypes, storeModuleDestination,
            storeCurrentLocations, prev) =>
        prev!
          ..setStores(storeContainerTypes, storeModuleDestination,
              storeCurrentLocations));
