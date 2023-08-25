import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/module_destination.dart';

import 'container_type.dart';

class StoreContainerTypes extends FirebaseStore<ContainerType> {
  StoreContainerTypes() : super('container_types', ContainerType.fromJson);
}

class StoreModuleDestination extends FirebaseStore<ModuleDestination> {
  StoreModuleDestination()
      : super('module_destinations', ModuleDestination.fromJson);
}

class StoreCurrentLocations extends FirebaseStore<CurrentLocation> {
  StoreCurrentLocations()
      : super('current_locations', CurrentLocation.fromJson);
}
