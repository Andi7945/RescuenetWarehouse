import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rescuenet_warehouse/models/assignment.dart';
import 'package:rescuenet_warehouse/models/container_type.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import '../models/container_dao.dart';

final containersCollection = FirebaseFirestore.instance
    .collection("containers")
    .withConverter<ContainerDao>(
        fromFirestore: (snapshot, _) => ContainerDao.fromJson(snapshot.data()!),
        toFirestore: (ContainerDao type, _) => type.toJson());

final itemsCollection = FirebaseFirestore.instance
    .collection("items")
    .withConverter<Item>(
        fromFirestore: (snapshot, _) => Item.fromJson(snapshot.data()!),
        toFirestore: (Item type, _) => type.toJson());

final workLogCollection = FirebaseFirestore.instance
    .collection("work_log")
    .withConverter<LogEntry>(
        fromFirestore: (snapshot, _) => LogEntry.fromJson(snapshot.data()!),
        toFirestore: (LogEntry type, _) => type.toJson());

final currentLocationsCollection = FirebaseFirestore.instance
    .collection("current_locations")
    .withConverter<CurrentLocation>(
        fromFirestore: (snapshot, _) =>
            CurrentLocation.fromJson(snapshot.data()!),
        toFirestore: (CurrentLocation type, _) => type.toJson());

final moduleDestinationsCollection = FirebaseFirestore.instance
    .collection("module_destinations")
    .withConverter<ModuleDestination>(
        fromFirestore: (snapshot, _) =>
            ModuleDestination.fromJson(snapshot.data()!),
        toFirestore: (ModuleDestination type, _) => type.toJson());

final containerTypesCollection = FirebaseFirestore.instance
    .collection("container_types")
    .withConverter<ContainerType>(
        fromFirestore: (snapshot, _) =>
            ContainerType.fromJson(snapshot.data()!),
        toFirestore: (ContainerType type, _) => type.toJson());

final assignmentCollection = FirebaseFirestore.instance
    .collection("assignments")
    .withConverter<Assignment>(
        fromFirestore: (snapshot, _) => Assignment.fromJson(snapshot.data()!),
        toFirestore: (Assignment type, _) => type.toJson());
