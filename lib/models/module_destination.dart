import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/features/printing/domain/priority_badge_config.dart';

part 'module_destination.freezed.dart';

part 'module_destination.g.dart';

@freezed
abstract class ModuleDestination with _$ModuleDestination {
  const factory ModuleDestination({
    required String id,
    required String name,
    @Default(1) int priority,
    PriorityBadgeShape? badgeShape,  // NEW: nullable for backward compat
  }) = _ModuleDestination;

  factory ModuleDestination.fromJson(Map<String, dynamic> json) =>
      _$ModuleDestinationFromJson(json);
}
