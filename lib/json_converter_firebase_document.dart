import 'package:json_annotation/json_annotation.dart';

import 'firebase_document.dart';

class FirebaseDocumentConverter
    extends JsonConverter<FirebaseDocument, Map<String, dynamic>> {
  const FirebaseDocumentConverter();

  @override
  Map<String, dynamic> toJson(Object doc) => (doc as FirebaseDocument).toJson();

  @override
  FirebaseDocument fromJson(Map<String, dynamic> json) =>
      FirebaseDocument.fromJson(json);
}
