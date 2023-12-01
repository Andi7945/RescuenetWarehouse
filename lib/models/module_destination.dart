import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'module_destination.freezed.dart';

part 'module_destination.g.dart';

@freezed
class ModuleDestination
    with _$ModuleDestination
    implements FirebaseStorable<ModuleDestination> {
  const factory ModuleDestination({
    required String id,
    required String name,
  }) = _ModuleDestination;

  factory ModuleDestination.fromJson(Map<String, dynamic> json) =>
      _$ModuleDestinationFromJson(json);
}
