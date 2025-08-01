import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_destinations_notifier.g.dart';

@riverpod
class ModuleDestinationsNotifier extends _$ModuleDestinationsNotifier {
  @override
  List<ModuleDestination> build() {
    final repository = ref.watch(moduleDestinationRepositoryProvider);
    
    // Subscribe to stream and update state when data changes
    repository.watchModuleDestinations().listen((moduleDestinations) {
      if (mounted) {
        state = moduleDestinations;
      }
    });
    
    return [];
  }

  ModuleDestination? find(String? id) {
    if (id == null) return null;
    var res = state.firstWhereOrNull((t) => t.id == id);
    if (res == null) {
      print("Could not find Module Destination $id!");
    }
    return res;
  }

  Future<void> upsert(ModuleDestination destination) async {
    final repository = ref.read(moduleDestinationRepositoryProvider);
    if (destination.id.isEmpty) {
      await repository.createModuleDestination(destination);
    } else {
      await repository.updateModuleDestination(destination);
    }
  }

  delete(ModuleDestination? destination) async {
    if (destination == null) return;
    final repository = ref.read(moduleDestinationRepositoryProvider);
    await repository.deleteModuleDestination(destination.id);
  }
}
