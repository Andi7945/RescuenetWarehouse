import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/rescue_container.dart';
import 'current_item_assignments_notifier.dart';

part 'current_item_assignments_not_null_notifier.g.dart';

@riverpod
class CurrentItemAssignmentsNotNullNotifier
    extends _$CurrentItemAssignmentsNotNullNotifier {
  @override
  Map<RescueContainer, int> build() {
    var used = Map.fromEntries(ref
        .watch(currentItemAssignmentsNotifierProvider)
        .entries
        .where((e) => e.value != 0));
    return used;
  }
}
