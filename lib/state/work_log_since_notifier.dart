import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/models/log_entry_summed.dart';
import 'package:rescuenet_warehouse/state/all_work_logs_notifier.dart';
import 'package:rescuenet_warehouse/state/work_log_date_filter_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';

import '../ui/work_log_page/work_log_helper.dart';

part 'work_log_since_notifier.g.dart';

@riverpod
class WorkLogSinceNotifier extends _$WorkLogSinceNotifier {
  @override
  Map<String, List<LogEntrySummed>> build() {
    return logs().groupBy((f) => f.containerId).mapValues(sumDailyChanges);
  }

  Iterable<LogEntry> logs() {
    var logs = ref.watch(allWorkLogsNotifierProvider);
    var date = ref.watch(workLogDateFilterNotifierProvider);
    if (date != null) {
      return logs.where((e) => e.date.isAfter(date));
    }
    return logs;
  }
}
