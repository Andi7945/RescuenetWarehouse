import 'dart:core';
import 'package:flutter/material.dart';

class SingleRNItemModel{
  String id;
  bool isBox;
  int? number;
  String name;
  String? imagePath;
  String? euroCrate;
  double? weight; // only if not a box
  int amount = 1; // only if not a box
  String? moduleDestination;
  bool checked = false;
  List<num> signeIDs = [];
  List<String> contains = [];
  String? sequentialBuildId;

  SingleRNItemModel({
    required this.id,
    this.imagePath,
    this.amount = 1,
    this.isBox = false,
    this.number,
    required this.name,
    this.sequentialBuildId,
    this.euroCrate,
    this.weight,
    this.moduleDestination,
    this.checked = false,
    this.signeIDs = const [],
    this.contains = const [],
  });

  // to json
  Map<String, dynamic> toJson() => {
    'imagePath': imagePath,
    'amount': amount,
    'isBox': isBox,
    'number': number,
    'name': name,
    'euroCrate': euroCrate,
    'weight': weight,
    'moduleDestination': moduleDestination,
    'checked': checked,
    'signeIDs': signeIDs,
    'sequentialBuildId': sequentialBuildId,
    'contains': contains,
  };

  // from json
  factory SingleRNItemModel.fromJson(Map<String, dynamic> json, String id) {
    return SingleRNItemModel(
      id: id,
      isBox: json['isBox'],
      number: json['number'],
      name: json['name'],
      euroCrate: json['euroCrate'],
      weight: json['weight'],
      moduleDestination: json['moduleDestination'],
      checked: json['checked'],
      signeIDs: json['signeIDs'].cast<num>(),
      sequentialBuildId: json['sequentialBuildId'],
      imagePath: json['imagePath'],
      amount: json['amount'],
      contains: json['contains'].cast<String>(),
    );
  }

}

