import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/container_type.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'container_types_notifier.g.dart';

@riverpod
class ContainerTypesNotifier extends _$ContainerTypesNotifier {
  @override
  List<ContainerType> build() {
    final repository = ref.watch(containerTypeRepositoryProvider);

    // Use proper stream subscription management
    final subscription = repository.watchContainerTypes().listen((
      containerTypes,
    ) {
      state = containerTypes;
    });

    // Dispose subscription when notifier is disposed
    ref.onDispose(() {
      subscription.cancel();
    });

    return [];
  }

  ContainerType? find(String? id) {
    if (id == null) return null;
    var res = state.firstWhereOrNull((t) => t.id == id);
    if (res == null) {
      print("Could not find Container Type $id!");
    }
    return res;
  }

  Future<void> upsert(ContainerType type) async {
    final repository = ref.read(containerTypeRepositoryProvider);
    if (type.id.isEmpty) {
      await repository.createContainerType(type);
    } else {
      await repository.updateContainerType(type);
    }
  }

  delete(ContainerType? type) async {
    if (type == null) return;
    final repository = ref.read(containerTypeRepositoryProvider);
    await repository.deleteContainerType(type.id);
  }
}

@riverpod
class ContainerTypesAsync extends _$ContainerTypesAsync {
  @override
  Stream<List<ContainerType>> build() {
    final repository = ref.watch(containerTypeRepositoryProvider);
    return repository.watchContainerTypes();
  }
}
