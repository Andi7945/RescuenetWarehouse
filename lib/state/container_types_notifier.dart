import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/db/container_types_data.dart';
import 'package:rescuenet_warehouse/models/container_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'container_types_notifier.g.dart';

@riverpod
class ContainerTypesNotifier extends _$ContainerTypesNotifier {
  @override
  List<ContainerType> build() {
    return ref.watch(containerTypesDataProvider);
  }

  ContainerType? find(String? id) {
    if (id == null) return null;
    var res = state.firstWhereOrNull((t) => t.id == id);
    if (res == null) {
      print("Could not find Container Type $id!");
    }
    return res;
  }

  Future<void> upsert(ContainerType type) =>
      ref.read(containerTypesDataProvider.notifier).upsert(type);

  delete(ContainerType? type) async =>
      ref.read(containerTypesDataProvider.notifier).delete(type);
}
