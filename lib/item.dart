import 'sign.dart';

class Item {
  String id;
  String? name;
  String imagePath = "https://via.placeholder.com/90x81";
  String? rescueNetId;
  double weight = 0.0;
  int totalAmount;
  String? description;
  List<String> expiringDates = List.empty();
  String? operationalStatus;
  String? manufacturer;
  String? brand;
  String? type;
  String? supplier;
  String? website;
  String? value;
  String? sku;
  String? notes;
  List<Sign> signs = List.empty();

  Item(this.id, this.totalAmount);

  Item.filled(this.id,
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

  Item.simple(this.id, this.name, this.weight, this.totalAmount);
}

/**
 * id
    name
    rescue net id
    image path
    description
    []expiring dates
    operational status
    manufacturer
    brand
    type
    supplier
    website
    value
    notes
    []signs
    UN Number
    image path
    instructions
    remarks
    sds path
    []other documents
 */