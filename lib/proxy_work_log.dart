import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/log_entry_expanded.dart';
import 'package:rescuenet_warehouse/store.dart';
import 'package:rescuenet_warehouse/work_log_store.dart';

ProxyProvider2 proxyWorkLog() =>
    ProxyProvider2<WorkLogStore, Store, Map<String, List<LogEntryExpanded>>>(
        update: (ctx, WorkLogStore workLogStore, Store store, prev) =>
            workLogStore.logEntries.map((k, v) => MapEntry(
                k,
                v.entries
                    .map((e) => _expandEntry(store, e.key, e.value))
                    .toList())));

LogEntryExpanded _expandEntry(Store store, ItemAndContainer itemAndContainer,
        CountAndUser countAndUser) =>
    LogEntryExpanded(
        store.itemById(itemAndContainer.itemId),
        store.containers.firstWhere(
            (element) => element.id == itemAndContainer.containerId),
        countAndUser.count,
        countAndUser.user);
