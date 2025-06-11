import 'package:rescuenet_warehouse/db/work_log_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/log_entry.dart';

part 'all_work_logs_notifier.g.dart';

@riverpod
class AllWorkLogsNotifier extends _$AllWorkLogsNotifier {
  @override
  List<LogEntry> build() {
    return ref.watch(workLogDataProvider);
  }
}
