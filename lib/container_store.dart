import 'dart:collection';

import 'package:flutter/material.dart';

import 'container_dao.dart';
import 'data_mocks.dart';

class ContainerStore extends ChangeNotifier {
  final Map<String, ContainerDao> containers = {
    container_office.id: container_office,
    container_power.id: container_power,
    container_medical.id: container_medical
  };

  UnmodifiableListView<ContainerDao> get containerValues =>
      UnmodifiableListView(containers.values);

  updateContainer(ContainerDao container) {
    containers[container.id] = container;
    notifyListeners();
  }
}
