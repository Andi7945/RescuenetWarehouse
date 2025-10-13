import 'package:freezed_annotation/freezed_annotation.dart';

part 'packing_item.freezed.dart';

@freezed
abstract class PackingItem with _$PackingItem {
  const factory PackingItem({
    required String name,
    required String description,
    required double amount,
    required double piecePrice,
    required double weightTotal,
    required DateTime? expirationDate,
    required String dangerousGoods,
    required String remarks,
  }) = _PackingItem;
}
