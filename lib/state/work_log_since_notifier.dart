import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/models/log_entry_summed.dart';
import 'package:rescuenet_warehouse/state/work_logs_by_date_range_notifier.dart';
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
    var date = ref.watch(workLogDateFilterNotifierProvider);

    if (date == null) {
      // No date filter - return empty list (or could use a very old date)
      return <LogEntry>[];
    }

    // Use fine-grained date range provider
    // Set end date far in future to get all logs after start date
    final endDate = DateTime(2100, 1, 1);
    var logsAsync = ref.watch(workLogsByDateRangeProvider(date, endDate));

    return logsAsync.when(
      data: (logs) => logs,
      loading: () => <LogEntry>[],
      error: (e, _) => <LogEntry>[],
    );
  }
}
