import 'package:freezed_annotation/freezed_annotation.dart';

part 'packing_dangerous_good.freezed.dart';

@freezed
abstract class PackingDangerousGood with _$PackingDangerousGood {
  const factory PackingDangerousGood({
    required String dangerType,
    required String iataId,
    required String properShippingName,
    required double maxWeightPAX,
    required double maxWeightCargo,
    required String remarks,
    required String imagePath,
  }) = _PackingDangerousGood;
}
