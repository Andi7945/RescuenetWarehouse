import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_mapper_service.dart';
import 'package:rescuenet_warehouse/container_store.dart';

import 'container_dao.dart';
import 'container_service.dart';
import 'data_mocks.dart';
import 'filter.dart';
import 'rescue_container.dart';

class ContainerVisibilityService extends ChangeNotifier {
  late ContainerMapperService mapperService;
  late ContainerService containerService;
  Map<double, ContainerDao> containers = {};
  ValueNotifier<Filter> currentFilter =
      ValueNotifier(Filter(FilterField.containerName, ""));
  VoidCallback? listener;

  updateContainers(Map<double, ContainerDao> containers,
      ContainerMapperService mapperService, ContainerService containerService) {
    this.containers = containers;
    this.mapperService = mapperService;
    this.containerService = containerService;

    if (listener != null) {
      currentFilter.removeListener(listener!);
      listener = null;
    }
    currentFilter.addListener(() {
      notifyListeners();
    });

    for (var e in containers.keys) {
      containerVisibility.putIfAbsent(e, () => true);
    }
  }

  final Map<double, bool> containerVisibility = {
    container_office.id: true,
    container_power.id: true,
    container_medical.id: true
  };

  changeContainerVisibility(RescueContainer c) {
    containerVisibility.update(c.id, (value) => !value);
    notifyListeners();
  }

  changeAllContainerVisibility(bool shown) {
    containerVisibility.updateAll((key, value) => value = shown);
    notifyListeners();
  }

  Map<RescueContainer, bool> containerWithVisible() => containerVisibility.map(
      (key, value) => MapEntry(mapperService.fromDao(containers[key]!), value));

  Map<RescueContainer, bool> get filteredContainer {
    var containers = containerWithVisible();
    var withItems = containerService.containerWithItems();
    if (currentFilter.value.value != null) {
      containers.removeWhere((key, value) {
        var currentWithItems = withItems[key];
        return !currentFilter.value.fn(key, currentWithItems?.keys ?? []);
      });
    }
    return containers;
  }
}

ChangeNotifierProxyProvider3 provideVisibilityService() =>
    ChangeNotifierProxyProvider3<ContainerStore, ContainerMapperService,
            ContainerService, ContainerVisibilityService>(
        create: (ctx) => ContainerVisibilityService(),
        update: (ctx, store, mapperService, service, prev) =>
            prev!..updateContainers(store.containers, mapperService, service));
