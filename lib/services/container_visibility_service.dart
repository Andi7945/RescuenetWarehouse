import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/services/container_mapper_service.dart';
import 'package:rescuenet_warehouse/stores.dart';

import '../models/container_dao.dart';
import 'container_service.dart';
import '../filter.dart';
import '../models/rescue_container.dart';

class ContainerVisibilityService extends ChangeNotifier {
  late ContainerMapperService mapperService;
  late ContainerService containerService;
  Map<String, ContainerDao> containers = {};
  ValueNotifier<Filter> currentFilter =
      ValueNotifier(Filter(FilterField.all, ""));

  init(List<ContainerDao> conts, ContainerMapperService mapperService,
      ContainerService containerService) {
    containers = Map.fromEntries(conts.map((e) => MapEntry(e.id, e)));
    this.mapperService = mapperService;
    this.containerService = containerService;

    if (!currentFilter.hasListeners) {
      currentFilter.addListener(() {
        notifyListeners();
      });
    }

    for (var e in containers.keys) {
      _containerVisibility.putIfAbsent(e, () => true);
    }
    _containerVisibility
        .removeWhere((key, value) => !containers.keys.contains(key));
  }

  final Map<String, bool> _containerVisibility = {};

  changeContainerVisibility(RescueContainer c) {
    _containerVisibility.update(c.id, (value) => !value);
    notifyListeners();
  }

  Map<RescueContainer, bool> unfilteredContainerWithVisible() =>
      _containerVisibility.map((key, value) =>
          MapEntry(mapperService.fromDao(containers[key]!), value));

  Map<RescueContainer, bool> get filteredContainer {
    var containers = unfilteredContainerWithVisible();
    var withItems = containerService.containerWithItems();
    if (currentFilter.value.value != null) {
      containers.removeWhere((key, value) {
        var currentWithItems = withItems[key];
        return !currentFilter.value.matches(key, currentWithItems?.keys ?? []);
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
            prev!..init(store.all, mapperService, service));
