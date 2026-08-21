import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_destination.freezed.dart';

part 'module_destination.g.dart';

@freezed
abstract class ModuleDestination with _$ModuleDestination {
  const factory ModuleDestination({
    required String id,
    required String name,

    /// Load priority 1 (first) .. 4 (last). `null` means not configured yet -
    /// such destinations sort last. Nullable because existing Firestore
    /// documents predate this field.
    int? priority,
  }) = _ModuleDestination;

  factory ModuleDestination.fromJson(Map<String, dynamic> json) =>
      _$ModuleDestinationFromJson(json);
}
