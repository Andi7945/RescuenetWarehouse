import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rescuenet_warehouse/firebase_document.dart';
import 'package:rescuenet_warehouse/json_converter_firebase_document.dart';

part 'sign.freezed.dart';

part 'sign.g.dart';

@freezed
class Sign with _$Sign {
  const factory Sign({
    required String id,
    String? unNumber,
    String? imagePath,
    String? instructions,
    String? remarks,
    @FirebaseDocumentConverter() @Default([]) List<FirebaseDocument> sdsPath,
    String? dangerType,
    String? properShippingName,
    @Default(0.0) double maxWeightPAX,
    @Default(0.0) double maxWeightCargo,
    @FirebaseDocumentConverter()
    @Default([])
    List<FirebaseDocument> otherDocuments,
  }) = _Sign;

  factory Sign.fromJson(Map<String, dynamic> json) => _$SignFromJson(json);
}
