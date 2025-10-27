import 'package:json_annotation/json_annotation.dart';

class StringConverter implements JsonConverter<String?, dynamic> {
  const StringConverter();

  /// If there is a number in the field, Json will write out a number for the string field.
  /// When trying to import the same record again that will fail. So we use toString here for non String? values in a String? field.

  @override
  String? fromJson(dynamic input) {
    if (input is String?) {
      return input;
    }
    return input.toString();
  }

  @override
  String? toJson(String? fromModel) => fromModel;
}
