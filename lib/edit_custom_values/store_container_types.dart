import 'dart:collection';

import 'package:flutter/material.dart';

import '../container_type.dart';
import '../data_mocks.dart';

class StoreContainerTypes extends ChangeNotifier {
  final List<ContainerType> _list = [
    container_type_crate,
    container_type_backpack
  ];

  UnmodifiableListView<ContainerType> get containerTypes =>
      UnmodifiableListView(_list);

  ContainerType get(String? typeId) =>
      _list.firstWhere((element) => element.id == typeId);

  add(ContainerType? type) {
    if (type != null && !_list.contains(type)) {
      _list.add(type);
      notifyListeners();
    }
  }

  remove(ContainerType? type) {
    if (_list.contains(type)) {
      _list.remove(type);
      notifyListeners();
    }
  }

  edit(ContainerType old, ContainerType newValue) {
    var idx = _list.indexOf(old);
    if (idx != -1) {
      _list.replaceRange(idx, idx + 1, [newValue]);
      notifyListeners();
    }
  }
}
