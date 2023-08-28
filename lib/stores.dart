import 'package:rescuenet_warehouse/assignment.dart';
import 'package:rescuenet_warehouse/container_dao.dart';
import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/log_entry.dart';
import 'package:rescuenet_warehouse/module_destination.dart';

import 'container_type.dart';
import 'item.dart';

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