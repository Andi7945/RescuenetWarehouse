import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/sequential_build.dart';

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

  ContainerDao newContainer() {
    var newContainer = ContainerDao(uuid.v4(), "", null, null,
        SequentialBuild.firstBuild, null, null, false, false);
    containers[newContainer.id] = newContainer;
    return newContainer;
  }
}
