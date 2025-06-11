import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/db/current_locations_data.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_locations_notifier.g.dart';

@riverpod
class CurrentLocationsNotifier extends _$CurrentLocationsNotifier {
  @override
  List<CurrentLocation> build() {
    return ref.watch(currentLocationsDataProvider);
  }

  CurrentLocation? find(String? id) {
    if (id == null) return null;
    var res = state.firstWhereOrNull((t) => t.id == id);
    if (res == null) {
      print("Could not find Current Location $id!");
    }
    return res;
  }

  Future<void> upsert(CurrentLocation location) =>
      ref.read(currentLocationsDataProvider.notifier).upsert(location);

  delete(CurrentLocation? location) async =>
      ref.read(currentLocationsDataProvider.notifier).delete(location);
}
