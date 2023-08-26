import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rescuenet_warehouse/firebase_store.dart';
import 'package:rescuenet_warehouse/json_converter_sign.dart';
import 'package:rescuenet_warehouse/json_converter_timestamp.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:json_annotation/json_annotation.dart';

import 'sign.dart';

part 'item.g.dart';

@JsonSerializable()
class Item implements FirebaseStorable<Item> {
  @override
  String id;
  String? name;
  String imagePath = "https://via.placeholder.com/90x81";
  double rescueNetId;
  double weight = 0.0;
  int totalAmount;
  String? description;
  @TimestampConverter()
  List<DateTime> expiringDates = List.empty();
  OperationalStatus operationalStatus = OperationalStatus.deployable;
  String? manufacturer;
  String? brand;
  String? type;
  String? supplier;
  String? website;
  String? remarks;
  int value = 0;
  String? sku;
  String? notes;
  @JsonKey(defaultValue: [])
  @SignConverter()
  List<Sign> signs = List.empty();
  bool isColdChain = false;

  Item(this.id, this.totalAmount, this.rescueNetId);

  Item.filled(
      this.id,
      this.name,
      this.imagePath,
      this.rescueNetId,
      this.weight,
      this.totalAmount,
      this.description,
      this.expiringDates,
      this.operationalStatus,
      this.manufacturer,
      this.brand,
      this.type,
      this.supplier,
      this.website,
      this.value,
      this.notes,
      this.sku,
      this.isColdChain,
      this.remarks,
      this.signs);

  Item.simple(this.id, this.name, this.weight, this.totalAmount,
      this.operationalStatus, this.imagePath, this.rescueNetId,
      [bool? isColdChain])
      : isColdChain = isColdChain ?? false;

  Item.from(
      {required Item item,
      String? id,
      String? name,
      String? imagePath,
      double? rescueNetId,
      double? weight,
      int? totalAmount,
      String? description,
      List<DateTime>? expiringDates,
      OperationalStatus? operationalStatus,
      String? manufacturer,
      String? brand,
      String? type,
      String? supplier,
      String? website,
      int? value,
      String? sku,
      String? notes,
      String? remarks,
      bool? isColdChain,
      List<Sign>? signs})
      : id = id ?? item.id,
        name = name ?? item.name,
        imagePath = imagePath ?? item.imagePath,
        rescueNetId = rescueNetId ?? item.rescueNetId,
        weight = weight ?? item.weight,
        totalAmount = totalAmount ?? item.totalAmount,
        description = description ?? item.description,
        expiringDates = expiringDates ?? item.expiringDates,
        operationalStatus = operationalStatus ?? item.operationalStatus,
        manufacturer = manufacturer ?? item.manufacturer,
        brand = brand ?? item.brand,
        type = type ?? item.type,
        supplier = supplier ?? item.supplier,
        website = website ?? item.website,
        value = value ?? item.value,
        sku = sku ?? item.sku,
        notes = notes ?? item.notes,
        remarks = remarks ?? item.remarks,
        isColdChain = isColdChain ?? item.isColdChain,
        signs = signs ?? item.signs;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
