import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/log_entry_expanded.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

import 'item_service.dart';

ProxyProvider3 proxyWorkLog() => ProxyProvider3<ContainerService, WorkLogStore,
        ItemService, Map<String, List<LogEntryExpanded>>>(
    update: (ctx, containerService, WorkLogStore workLogStore,
            ItemService itemService, prev) =>
        workLogStore.logEntries.map((k, v) => MapEntry(
            k,
            v.entries
                .map((e) =>
                    _expandEntry(containerService, itemService, e.key, e.value))
                .toList())));

LogEntryExpanded _expandEntry(ContainerService service, ItemService itemService,
        ItemAndContainer itemAndContainer, CountAndUser countAndUser) =>
    LogEntryExpanded(
        itemService.itemById(itemAndContainer.itemId),
        service.containerValues.firstWhere(
            (element) => element.id == itemAndContainer.containerId),
        countAndUser.count,
        countAndUser.user);
