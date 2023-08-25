import 'package:provider/provider.dart';

import 'container_dao.dart';
import 'stores.dart';
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
      dao.typeId == null ? null : storeContainerTypes.get(dao.typeId),
      dao.moduleDestinationId == null
          ? null
          : storeModuleDestination.get(dao.moduleDestinationId),
      dao.currentLocationId == null
          ? null
          : storeCurrentLocations.get(dao.currentLocationId));
}

ProxyProvider3 provideMapperService() => ProxyProvider3<StoreContainerTypes,
        StoreModuleDestination, StoreCurrentLocations, ContainerMapperService>(
    create: (ctx) => ContainerMapperService(),
    update: (ctx, storeContainerTypes, storeModuleDestination,
            storeCurrentLocations, prev) =>
        prev!
          ..setStores(storeContainerTypes, storeModuleDestination,
              storeCurrentLocations));
