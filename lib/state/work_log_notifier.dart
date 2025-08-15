import 'package:rescuenet_warehouse/models/log_entry_summed.dart';
import 'package:rescuenet_warehouse/state/all_work_logs_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import "package:collection/collection.dart";

import '../models/log_entry.dart';
import '../ui/work_log_page/work_log_helper.dart';

part 'work_log_notifier.g.dart';

@riverpod
class WorkLogNotifier extends _$WorkLogNotifier {
  @override
  List<MapEntry<DateTime, List<MapEntry<String, List<LogEntrySummed>>>>> build() {
    var logsAsync = ref.watch(allWorkLogsAsyncProvider);
    
    return logsAsync.when(
      data: (logs) {
        Map<DateTime, List<LogEntry>> byDate = logs.groupBy((y) => y.date.asDay());
        var grouped = byDate.mapValues(sumDailyChanges).mapValues((x) =>
            x.groupBySorted((p0) => p0.containerId, (a, b) => a.compareTo(b)));

        return grouped.entries
            .sorted((a, b) =>
                b.key.millisecondsSinceEpoch - a.key.millisecondsSinceEpoch)
            .toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

extension DateTimeExtensions on DateTime {
  DateTime asDay() => DateTime(year, month, day);
}
