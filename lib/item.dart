import 'package:rescuenet_warehouse/operational_status.dart';

import 'sign.dart';

class Item {
  String id;
  String? name;
  String imagePath = "https://via.placeholder.com/90x81";
  String? rescueNetId;
  double weight = 0.0;
  int totalAmount;
  String? description;
  List<DateTime> expiringDates = List.empty();
  OperationalStatus operationalStatus = OperationalStatus.deployable;
  String? manufacturer;
  String? brand;
  String? type;
  String? supplier;
  String? website;
  int value = 0;
  String? sku;
  String? notes;
  List<Sign> signs = List.empty();

  Item(this.id, this.totalAmount);

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
      this.signs);

  Item.simple(this.id, this.name, this.weight, this.totalAmount,
      this.operationalStatus, this.imagePath);

  Item.from(
      {required Item item,
      String? id,
      String? name,
      String? imagePath,
      String? rescueNetId,
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
      List<Sign>? signs})
      : this.id = id ?? item.id,
        this.name = name ?? item.name,
        this.imagePath = imagePath ?? item.imagePath,
        this.rescueNetId = rescueNetId ?? item.rescueNetId,
        this.weight = weight ?? item.weight,
        this.totalAmount = totalAmount ?? item.totalAmount,
        this.description = description ?? item.description,
        this.expiringDates = expiringDates ?? item.expiringDates,
        this.operationalStatus = operationalStatus ?? item.operationalStatus,
        this.manufacturer = manufacturer ?? item.manufacturer,
        this.brand = brand ?? item.brand,
        this.type = type ?? item.type,
        this.supplier = supplier ?? item.supplier,
        this.website = website ?? item.website,
        this.value = value ?? item.value,
        this.sku = sku ?? item.sku,
        this.notes = notes ?? item.notes,
        this.signs = signs ?? item.signs;
}
