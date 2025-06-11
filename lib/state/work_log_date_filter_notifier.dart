import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'work_log_date_filter_notifier.g.dart';

@riverpod
class WorkLogDateFilterNotifier extends _$WorkLogDateFilterNotifier {

  @override
  DateTime? build() {
    return null;
  }

  saveDate(DateTime? choosen) {
    state = choosen;
  }
}