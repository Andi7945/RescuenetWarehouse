import 'dart:collection';

import 'package:flutter/foundation.dart';

class StoreModuleDestination extends ChangeNotifier {
  final List<String> _moduleDestinations = ["Office", "Warehouse"];

  UnmodifiableListView<String> get moduleDestinations =>
      UnmodifiableListView(_moduleDestinations);

  addDestination(String? text) {
    if (text != null && !_moduleDestinations.contains(text)) {
      _moduleDestinations.add(text);
      notifyListeners();
    }
  }

  removeDestination(String? text) {
    if (_moduleDestinations.contains(text)) {
      _moduleDestinations.remove(text);
      notifyListeners();
    }
  }

  editDestination(String oldDest, String newDest) {
    var idx = _moduleDestinations.indexOf(oldDest);
    if (idx != -1) {
      _moduleDestinations.replaceRange(idx, idx + 1, [newDest]);
      notifyListeners();
    }
  }
}
