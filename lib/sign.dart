import 'package:json_annotation/json_annotation.dart';
import 'package:rescuenet_warehouse/firebase_document.dart';
import 'package:rescuenet_warehouse/json_converter_firebase_document.dart';

part 'sign.g.dart';

@JsonSerializable()
class Sign {
  String id;
  String? unNumber;
  String? imagePath;
  String? instructions;
  String? remarks;
  @JsonKey(defaultValue: [])
  @FirebaseDocumentConverter()
  List<FirebaseDocument>? sdsPath = List.empty();
  String? dangerType;
  String? properShippingName;
  double maxWeightPAX;
  double maxWeightCargo;

  List<String> otherDocuments = List.empty();

  Sign(this.id)
      : maxWeightPAX = 0.0,
        maxWeightCargo = 0.0;

  Sign.filled(
      {required this.id,
      this.unNumber,
      this.imagePath,
      this.instructions,
      this.remarks,
      this.sdsPath,
      this.dangerType,
      this.properShippingName,
      required this.maxWeightPAX,
      required this.maxWeightCargo});

  Sign copyWith(
          {String? id,
          String? unNumber,
          String? imagePath,
          String? instructions,
          String? remarks,
          List<FirebaseDocument>? sdsPath,
          String? dangerType,
          String? properShippingName,
          double? maxWeightPAX,
          double? maxWeightCargo,
          List<String>? otherDocuments}) =>
      Sign.from(
          sign: this,
          id: id,
          unNumber: unNumber,
          imagePath: imagePath,
          instructions: instructions,
          remarks: remarks,
          sdsPath: sdsPath,
          dangerType: dangerType,
          properShippingName: properShippingName,
          maxWeightCargo: maxWeightCargo,
          maxWeightPAX: maxWeightPAX,
          otherDocuments: otherDocuments);

  Sign.from(
      {required Sign sign,
      String? id,
      String? unNumber,
      String? imagePath,
      String? instructions,
      String? remarks,
      List<FirebaseDocument>? sdsPath,
      String? dangerType,
      String? properShippingName,
      double? maxWeightPAX,
      double? maxWeightCargo,
      List<String>? otherDocuments})
      : id = id ?? sign.id,
        unNumber = unNumber ?? sign.unNumber,
        imagePath = imagePath ?? sign.imagePath,
        instructions = instructions ?? sign.instructions,
        remarks = remarks ?? sign.remarks,
        sdsPath = sdsPath ?? sign.sdsPath,
        dangerType = dangerType ?? sign.dangerType,
        properShippingName = properShippingName ?? sign.properShippingName,
        maxWeightPAX = maxWeightPAX ?? sign.maxWeightPAX,
        maxWeightCargo = maxWeightCargo ?? sign.maxWeightCargo,
        otherDocuments = otherDocuments ?? sign.otherDocuments;

  factory Sign.fromJson(Map<String, dynamic> json) => _$SignFromJson(json);

  Map<String, dynamic> toJson() => _$SignToJson(this);
}
