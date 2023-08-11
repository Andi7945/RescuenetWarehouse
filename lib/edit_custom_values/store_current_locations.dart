import "package:collection/collection.dart";
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/current_location.dart';
import 'package:rescuenet_warehouse/main.dart';

class StoreCurrentLocations extends ChangeNotifier {
  final List<CurrentLocation> _list = [
    CurrentLocation("1", "Warehouse Shiphole NL"),
    CurrentLocation("2", "Office")
  ];

  UnmodifiableListView<CurrentLocation> get currentLocations =>
      UnmodifiableListView(_list);

  CurrentLocation get(String? id) =>
      _list.firstWhere((element) => element.id == id);

  add(String? text) {
    if (text != null && _list.none((l) => l.name == text)) {
      _list.add(CurrentLocation(uuid.v4(), text));
      notifyListeners();
    }
  }

  remove(CurrentLocation location) {
    _list.remove(location);
    notifyListeners();
  }

  edit(CurrentLocation edited) {
    _list.firstWhere((element) => element.id == edited.id).name = edited.name;
    notifyListeners();
  }
}
