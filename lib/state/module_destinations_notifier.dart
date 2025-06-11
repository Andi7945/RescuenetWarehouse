import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/db/module_destinations_data.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_destinations_notifier.g.dart';

@riverpod
class ModuleDestinationsNotifier extends _$ModuleDestinationsNotifier {
  @override
  List<ModuleDestination> build() {
    return ref.watch(moduleDestinationsDataProvider);
  }

  ModuleDestination? find(String? id) {
    if (id == null) return null;
    var res = state.firstWhereOrNull((t) => t.id == id);
    if (res == null) {
      print("Could not find Module Destination $id!");
    }
    return res;
  }

  Future<void> upsert(ModuleDestination destination) =>
      ref.read(moduleDestinationsDataProvider.notifier).upsert(destination);

  delete(ModuleDestination? destination) async =>
      ref.read(moduleDestinationsDataProvider.notifier).delete(destination);
}
