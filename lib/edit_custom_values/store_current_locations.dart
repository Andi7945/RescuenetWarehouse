import 'dart:collection';

import 'package:flutter/material.dart';

class StoreCurrentLocations extends ChangeNotifier {
  final List<String> _list = ["Warehouse Shiphole NL", "Office"];

  UnmodifiableListView<String> get currentLocations =>
      UnmodifiableListView(_list);

  add(String? text) {
    if (text != null && !_list.contains(text)) {
      _list.add(text);
      notifyListeners();
    }
  }

  remove(String? text) {
    if (_list.contains(text)) {
      _list.remove(text);
      notifyListeners();
    }
  }

  edit(String oldDest, String newDest) {
    var idx = _list.indexOf(oldDest);
    if (idx != -1) {
      _list.replaceRange(idx, idx + 1, [newDest]);
      notifyListeners();
    }
  }
}