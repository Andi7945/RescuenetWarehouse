import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'container_hidden_by_selection_notifier.g.dart';

@riverpod
class ContainerHiddenBySelectionNotifier
    extends _$ContainerHiddenBySelectionNotifier {
  @override
  List<RescueContainer> build() {
    return [];
  }

  changeVisibility(RescueContainer container) {
    if (state.contains(container)) {
      state = state.where((c) => c.id != container.id).toList();
    } else {
      state = [...state, container];
    }
  }
}
