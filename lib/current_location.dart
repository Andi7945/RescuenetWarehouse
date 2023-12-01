import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'current_location.freezed.dart';
part 'current_location.g.dart';

@freezed
class CurrentLocation
    with _$CurrentLocation
    implements FirebaseStorable<CurrentLocation> {
  const factory CurrentLocation({required String id, required String name}) =
      _CurrentLocation;

  factory CurrentLocation.fromJson(Map<String, Object?> json) =>
      _$CurrentLocationFromJson(json);
}
