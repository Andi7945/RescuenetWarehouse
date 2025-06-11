import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_location.freezed.dart';
part 'current_location.g.dart';

@freezed
abstract class CurrentLocation with _$CurrentLocation {
  const factory CurrentLocation({required String id, required String name}) =
      _CurrentLocation;

  factory CurrentLocation.fromJson(Map<String, Object?> json) =>
      _$CurrentLocationFromJson(json);
}
