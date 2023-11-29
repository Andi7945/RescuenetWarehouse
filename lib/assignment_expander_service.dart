import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/container_mapper_service.dart';
import 'package:rescuenet_warehouse/stores.dart';

import 'item.dart';
import 'rescue_container.dart';

class AssignmentExpanderService {
  final AssignmentStore _assignmentStore;
  final ContainerStore _containerStore;
  final ContainerMapperService _mapperService;
  final ItemStore _itemStore;

  AssignmentExpanderService(this._assignmentStore, this._containerStore,
      this._mapperService, this._itemStore);

  List<_AssignmentExpanded> _expandedAssignments() {
    if (!_assignmentStore.loaded ||
        !_containerStore.loaded ||
        !_itemStore.loaded ||
        !_mapperService.storesLoaded()) {
      return [];
    }

    return _assignmentStore.all
        .where((a) => a.count != 0)
        .map((a) => _AssignmentExpanded(
            a.id,
            _itemStore.get(a.itemId),
            _mapperService.fromDao(_containerStore.get(a.containerId)),
            a.count))
        .toList();
  }

  Map<Item, int> assignmentsFor([String? containerId]) => _expandedAssignments()
      .where((a) => containerId != null ? a.container.id == containerId : true)
      .groupBy((a) => a.item)
      .mapValues(_sumAmounts);

  int _sumAmounts(List<_AssignmentExpanded> assignments) => assignments.fold(
      0, (previousValue, element) => previousValue + element.count);

  Map<RescueContainer, int> assignmentsForItem(String itemId) =>
      _expandedAssignments()
          .where((a) => a.item.id == itemId)
          .groupBy((a) => a.container)
          .mapValues(_sumAmounts);
}

class _AssignmentExpanded {
  final String id;
  final Item item;
  final RescueContainer container;
  final int count;

  _AssignmentExpanded(this.id, this.item, this.container, this.count);
}

ProxyProvider4 provideAssignmentExpander() => ProxyProvider4<
        AssignmentStore,
        ContainerStore,
        ContainerMapperService,
        ItemStore,
        AssignmentExpanderService>(
    update: (ctxt, assignmentStore, containerStore, mapperService, itemStore,
            prev) =>
        AssignmentExpanderService(
            assignmentStore, containerStore, mapperService, itemStore));
