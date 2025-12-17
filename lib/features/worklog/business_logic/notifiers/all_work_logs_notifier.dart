import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/features/worklog/providers/work_log_providers.dart';

import '../../../../models/log_entry.dart';

part 'all_work_logs_notifier.g.dart';

@riverpod
class AllWorkLogsNotifier extends _$AllWorkLogsNotifier {
  @override
  List<LogEntry> build() {
    final repository = ref.watch(workLogRepositoryProvider);

    // Use proper stream subscription management
    final subscription = repository.watchWorkLogs().listen((workLogs) {
      state = workLogs;
    });

    // Dispose subscription when notifier is disposed
    ref.onDispose(() {
      subscription.cancel();
    });

    return [];
  }
}

@riverpod
class AllWorkLogsAsync extends _$AllWorkLogsAsync {
  @override
  Stream<List<LogEntry>> build() {
    final repository = ref.watch(workLogRepositoryProvider);
    return repository.watchWorkLogs();
  }
}
