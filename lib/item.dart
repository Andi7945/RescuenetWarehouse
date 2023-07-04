import 'sign.dart';

class Item {
  String id;
  String? name;
  String? rescueNetId;
  String? description;
  List<String> expiringDates = List.empty();
  String? operationalStatus;
  String? manufacturer;
  String? brand;
  String? type;
  String? supplier;
  String? website;
  String? value;
  String? notes;
  List<Sign> signs = List.empty();

  Item(this.id);
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