import 'package:json_annotation/json_annotation.dart';

part 'firebase_document.g.dart';

@JsonSerializable()
class FirebaseDocument {
  final String id;
  final String url;
  final String name;

  FirebaseDocument(this.id, this.url, this.name);

  factory FirebaseDocument.fromJson(Map<String, dynamic> json) =>
      _$FirebaseDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseDocumentToJson(this);
}
