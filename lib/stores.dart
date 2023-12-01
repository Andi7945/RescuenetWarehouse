import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';

import 'models/container_type.dart';
import 'models/item.dart';

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

class AssignmentStore extends FirebaseStore<Assignment> {
  AssignmentStore() : super('assignments', Assignment.fromJson);
}

class WorkLogStore extends FirebaseStore<LogEntry> {
  WorkLogStore() : super('work_log', LogEntry.fromJson);
}

class ContainerStore extends FirebaseStore<ContainerDao> {
  ContainerStore() : super('containers', ContainerDao.fromJson);
}

class ItemStore extends FirebaseStore<Item> {
  ItemStore() : super('items', Item.fromJson);
}