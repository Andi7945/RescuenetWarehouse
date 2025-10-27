import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/models/json_converter_timestamp.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';

import 'json_converter_string.dart';
import 'sign.dart';
import 'dart:convert';

part 'item.freezed.dart';

part 'item.g.dart';

@freezed
abstract class Item with _$Item {
  const Item._();

  const factory Item({
    required String id,
    String? name,
    @Default("") String imagePath,
    required double rescueNetId,
    @Default(0.0) double weight,
    required int totalAmount,
    String? description,
    @Default([]) @TimestampConverter() List<DateTime> expiringDates,
    @Default(OperationalStatus.deployable) OperationalStatus operationalStatus,
    @StringConverter() String? manufacturer,
    @StringConverter() String? brand,
    @StringConverter() String? type,
    @StringConverter() String? supplier,
    @StringConverter() String? website,
    @StringConverter() String? remarks,
    @Default(0) int value,
    @StringConverter() String? sku,
    String? notes,
    @Default([]) List<Sign> signs,
    @Default(false) bool isColdChain,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  factory Item.fromJsonWithDateString(Map<String, dynamic> jsonObject) {
    jsonObject["sku"] = jsonObject["sku"].toString();

    jsonObject["expiringDates"] = jsonObject["expiringDates"]
        .map((s) => Timestamp.fromDate(DateTime.parse(s)))
        .toList();

    var parsedItemWithoutDates = Item.fromJson(jsonObject);
    return parsedItemWithoutDates;
  }

  static List<DateTime> parseDateTimeList(String input) {
    // Remove the square brackets and split by comma if there are multiple dates
    String cleanInput = input.replaceAll("[", "").replaceAll("]", "");
    List<String> dateStrings = cleanInput.split(",");

    // Parse each string into a DateTime object
    List<DateTime> dateList = dateStrings.map((dateString) {
      // Trim any whitespace
      String trimmed = dateString.trim();
      // Parse the ISO 8601 format string to DateTime
      return DateTime.parse(trimmed);
    }).toList();

    return dateList;
  }

  Map<String, dynamic> toJsonWithDateString() {
    var item = copyWith(expiringDates: []);
    var jsonWithoutDates = item.toJson();
    var dates = expiringDates.map((d) => d.toIso8601String()).toList();
    jsonWithoutDates["expiringDates"] = dates;
    return jsonWithoutDates;
  }
}
