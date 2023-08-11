import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/log_entry_expanded.dart';
import 'package:rescuenet_warehouse/store.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

ProxyProvider3 proxyWorkLog() =>
    ProxyProvider3<ContainerService, WorkLogStore, Store, Map<String, List<LogEntryExpanded>>>(
        update: (ctx, containerService, WorkLogStore workLogStore, Store store, prev) =>
            workLogStore.logEntries.map((k, v) => MapEntry(
                k,
                v.entries
                    .map((e) => _expandEntry(containerService, store, e.key, e.value))
                    .toList())));

LogEntryExpanded _expandEntry(ContainerService service, Store store, ItemAndContainer itemAndContainer,
        CountAndUser countAndUser) =>
    LogEntryExpanded(
        store.itemById(itemAndContainer.itemId),
        service.containerValues.firstWhere(
            (element) => element.id == itemAndContainer.containerId),
        countAndUser.count,
        countAndUser.user);
