import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/json_converter_sign.dart';
import 'package:rescuenet_warehouse/json_converter_timestamp.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:json_annotation/json_annotation.dart';

import 'sign.dart';

part 'item.freezed.dart';

part 'item.g.dart';

@freezed
class Item with _$Item implements FirebaseStorable<Item> {
  const factory Item({
    required String id,
    String? name,
    @Default("https://via.placeholder.com/90x81") String imagePath,
    required double rescueNetId,
    @Default(0.0) double weight,
    required int totalAmount,
    String? description,
    @Default([]) @TimestampConverter() List<DateTime> expiringDates,
    @Default(OperationalStatus.deployable) OperationalStatus operationalStatus,
    String? manufacturer,
    String? brand,
    String? type,
    String? supplier,
    String? website,
    String? remarks,
    @Default(0) int value,
    String? sku,
    String? notes,
    @Default([]) @JsonKey(defaultValue: []) @SignConverter() List<Sign> signs,
    @Default(false) bool isColdChain,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
