import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_destination.freezed.dart';

part 'module_destination.g.dart';

@freezed
abstract class ModuleDestination with _$ModuleDestination {
  const factory ModuleDestination({
    required String id,
    required String name,
    @Default(1) int priority,
  }) = _ModuleDestination;

  factory ModuleDestination.fromJson(Map<String, dynamic> json) =>
      _$ModuleDestinationFromJson(json);
}
