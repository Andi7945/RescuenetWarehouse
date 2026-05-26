import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/rescue_container.dart';
import '../../../models/container_dao.dart';
import '../../../repositories/repository_providers.dart';
import '../../../state/all_containers_notifier.dart';
import 'renumber_entry.dart';
import 'renumber_validation.dart';

part 'container_renumber_notifier.g.dart';

@riverpod
class ContainerRenumberNotifier extends _$ContainerRenumberNotifier {
  @override
  List<RenumberEntry> build() {
    final containers =
        (ref.watch(allContainersAsyncProvider).valueOrNull ?? [])
          ..sort((a, b) => a.number.compareTo(b.number));
    return containers
        .map((c) => RenumberEntry(
              id: c.id,
              name: c.name,
              currentNumber: c.number,
              pendingNumber: c.number,
            ))
        .toList();
  }

  void updatePending(String containerId, int newNumber) {
    state = [
      for (final e in state)
        if (e.id == containerId) e.withPending(newNumber) else e,
    ];
  }

  Future<void> applyRenumbering() async {
    final changed = changedEntries(state);
    if (changed.isEmpty || !isValidRenumbering(state)) return;

    final containers =
        ref.read(allContainersAsyncProvider).valueOrNull ?? [];
    final updates = changed.map((entry) {
      final container = containers.firstWhere((c) => c.id == entry.id);
      final updated = container.copyWith(number: entry.pendingNumber);
      return ContainerDao.fromContainer(updated);
    }).toList();

    await ref
        .read(containerRepositoryProvider)
        .batchUpdateContainers(updates);
  }
}
