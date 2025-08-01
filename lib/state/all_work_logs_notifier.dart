import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

import '../models/log_entry.dart';

part 'all_work_logs_notifier.g.dart';

@riverpod
class AllWorkLogsNotifier extends _$AllWorkLogsNotifier {
  @override
  List<LogEntry> build() {
    final repository = ref.watch(workLogRepositoryProvider);
    
    // Subscribe to the stream and update state when data changes
    repository.watchWorkLogs().listen((workLogs) {
      if (mounted) {
        state = workLogs;
      }
    });
    
    return [];
  }
}
