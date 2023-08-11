import "package:collection/collection.dart";
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/module_destination.dart';

class StoreModuleDestination extends ChangeNotifier {
  final List<ModuleDestination> _moduleDestinations = [
    ModuleDestination("1", "Office"),
    ModuleDestination("2", "Warehouse")
  ];

  UnmodifiableListView<ModuleDestination> get moduleDestinations =>
      UnmodifiableListView(_moduleDestinations);

  ModuleDestination get(String? id) =>
      _moduleDestinations.firstWhere((element) => element.id == id);

  addDestination(String? text) {
    if (text != null && _moduleDestinations.none((d) => d.name == text)) {
      _moduleDestinations.add(ModuleDestination(uuid.v4(), text));
      notifyListeners();
    }
  }

  removeDestination(ModuleDestination dest) {
    _moduleDestinations.remove(dest);
    notifyListeners();
  }

  editDestination(ModuleDestination destination) {
    _moduleDestinations.firstWhere((d) => d.id == destination.id).name =
        destination.name;
    notifyListeners();
  }
}
