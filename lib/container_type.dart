import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';

part 'container_type.freezed.dart';

part 'container_type.g.dart';

@freezed
class ContainerType
    with _$ContainerType
    implements FirebaseStorable<ContainerType> {
  const factory ContainerType({
    required String id,
    required String name,
    String? imagePath,
    required double emptyWeight,
    required String measurements,
  }) = _ContainerType;

  factory ContainerType.fromJson(Map<String, Object?> json) =>
      _$ContainerTypeFromJson(json);
}
