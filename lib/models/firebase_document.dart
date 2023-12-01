import 'package:freezed_annotation/freezed_annotation.dart';

part 'firebase_document.freezed.dart';

part 'firebase_document.g.dart';

@freezed
class FirebaseDocument with _$FirebaseDocument {
  const factory FirebaseDocument(
      {required String id,
      required String url,
      required String name}) = _FirebaseDocument;

  factory FirebaseDocument.fromJson(Map<String, dynamic> json) =>
      _$FirebaseDocumentFromJson(json);
}
