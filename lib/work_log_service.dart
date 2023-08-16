import "package:collection/collection.dart";
import 'package:equatable/equatable.dart';

import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/container_visibility_service.dart';
import 'package:rescuenet_warehouse/log_entry.dart';
import 'package:rescuenet_warehouse/log_entry_expanded.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

import 'container_service.dart';
import 'item_service.dart';

class WorkLogService {
  final WorkLogStore workLogStore;
  final ContainerVisibilityService visibilityService;
  final ItemService itemService;
  final ContainerService containerService;

  WorkLogService(this.workLogStore, this.visibilityService, this.itemService,
      this.containerService);

  List<
          MapEntry<DateTime,
              List<MapEntry<RescueContainer, List<LogEntryExpanded>>>>>
      byDateAndContainerName() {
    Map<DateTime, List<LogEntry>> byDate =
        _visibleEntries().groupBy((y) => y.date.asDay());
    var grouped = byDate.mapValues(_sumDailyChanges).mapValues((v) => v.entries
        .map(_expandEntry)
        .groupBySorted((p0) => p0.container, (a, b) => a.id.compareTo(b.id)));

    return grouped.entries
        .sorted((a, b) =>
            b.key.millisecondsSinceEpoch - a.key.millisecondsSinceEpoch)
        .toList();
  }

  List<LogEntry> _visibleEntries() {
    var visible = visibilityService.containerVisibility;

    List<LogEntry> areVisible = workLogStore.entries
        .where((element) => visible[element.assignment.containerId] == true)
        .toList();
    return areVisible;
  }

  Map<ItemAndContainer, CountAndUser> _sumDailyChanges(
      Iterable<LogEntry> entries) {
    return entries
        .groupBy((p0) =>
            ItemAndContainer(p0.assignment.itemId, p0.assignment.containerId))
        .mapValues((value) => value.fold(
            CountAndUser({}, 0),
            (previousValue, element) => CountAndUser(
                previousValue.user..add(element.user),
                previousValue.count + element.assignment.count)));
  }

  LogEntryExpanded _expandEntry(MapEntry<ItemAndContainer, CountAndUser> e) =>
      LogEntryExpanded(
          itemService.itemById(e.key.itemId),
          containerService.containerValues
              .firstWhere((element) => element.id == e.key.containerId),
          e.value.count,
          e.value.user.join(","));

  Map<RescueContainer, List<LogEntryExpanded>> fromDate(DateTime onlyFromDate) {
    var filtered = _visibleEntries().where(
        (e) => e.date.add(const Duration(days: 1)).isAfter(onlyFromDate));
    return _sumDailyChanges(filtered)
        .entries
        .map(_expandEntry)
        .groupBy((p0) => p0.container);
  }
}

ProxyProvider4 provideWorkLogService() => ProxyProvider4<
        WorkLogStore,
        ContainerVisibilityService,
        ItemService,
        ContainerService,
        WorkLogService>(
    update: (ctx, store, visibilityService, itemService, containerService, _) =>
        WorkLogService(
            store, visibilityService, itemService, containerService));

extension DateTimeExtensions on DateTime {
  DateTime asDay() => DateTime(year, month, day);
}

class ItemAndContainer extends Equatable {
  final String itemId;
  final double containerId;

  ItemAndContainer(this.itemId, this.containerId);

  @override
  List<Object> get props => [itemId, containerId];
}

class CountAndUser extends Equatable {
  final Set<String> user;
  final int count;

  CountAndUser(this.user, this.count);

  @override
  List<Object> get props => [user, count];
}
