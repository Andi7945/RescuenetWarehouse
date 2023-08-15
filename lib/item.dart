import 'package:rescuenet_warehouse/operational_status.dart';

import 'sign.dart';

class Item {
  String id;
  String? name;
  String imagePath = "https://via.placeholder.com/90x81";
  String rescueNetId;
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
      this.signs);

  Item.simple(this.id, this.name, this.weight, this.totalAmount,
      this.operationalStatus, this.imagePath, this.rescueNetId);

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
        signs = signs ?? item.signs;
}
