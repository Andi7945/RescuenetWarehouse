import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_locations_notifier.g.dart';

@riverpod
class CurrentLocationsNotifier extends _$CurrentLocationsNotifier {
  @override
  List<CurrentLocation> build() {
    final repository = ref.watch(currentLocationRepositoryProvider);
    
    // Subscribe to stream and update state when data changes
    repository.watchCurrentLocations().listen((currentLocations) {
      if (mounted) {
        state = currentLocations;
      }
    });
    
    return [];
  }

  CurrentLocation? find(String? id) {
    if (id == null) return null;
    var res = state.firstWhereOrNull((t) => t.id == id);
    if (res == null) {
      print("Could not find Current Location $id!");
    }
    return res;
  }

  Future<void> upsert(CurrentLocation location) async {
    final repository = ref.read(currentLocationRepositoryProvider);
    if (location.id.isEmpty) {
      await repository.createCurrentLocation(location);
    } else {
      await repository.updateCurrentLocation(location);
    }
  }

  delete(CurrentLocation? location) async {
    if (location == null) return;
    final repository = ref.read(currentLocationRepositoryProvider);
    await repository.deleteCurrentLocation(location.id);
  }
}
