import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/sequential_build.dart';

import 'container_dao.dart';
import 'data_mocks.dart';

class ContainerStore extends ChangeNotifier {
  final Map<double, ContainerDao> containers = {
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
    var newContainerId = containers.keys.reduce(max) + 1;
    var newContainer = ContainerDao(newContainerId, "", null,
        SequentialBuild.firstBuild, null, null, false, false);
    containers[newContainer.id] = newContainer;
    return newContainer;
  }
}
