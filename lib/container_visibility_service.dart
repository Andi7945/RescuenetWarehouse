import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_mapper_service.dart';
import 'package:rescuenet_warehouse/container_store.dart';

import 'container_dao.dart';
import 'data_mocks.dart';
import 'rescue_container.dart';

class ContainerVisibilityService extends ChangeNotifier {
  late ContainerMapperService mapperService;
  Map<String, ContainerDao> containers = {};

  updateContainers(Map<String, ContainerDao> containers,
      ContainerMapperService mapperService) {
    this.containers = containers;
    this.mapperService = mapperService;
  }

  final Map<String, bool> containerVisibility = {
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
}

ChangeNotifierProxyProvider2 provideVisibilityService() =>
    ChangeNotifierProxyProvider2<ContainerStore, ContainerMapperService,
            ContainerVisibilityService>(
        create: (ctx) => ContainerVisibilityService(),
        update: (ctx, store, mapperService, prev) =>
            prev!..updateContainers(store.containers, mapperService));
