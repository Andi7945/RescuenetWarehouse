import 'package:json_annotation/json_annotation.dart';

import 'sign.dart';

class SignConverter extends JsonConverter<Sign, Map<String, dynamic>> {
  const SignConverter();

  @override
  Map<String, dynamic> toJson(Object sign) => (sign as Sign).toJson();

  @override
  Sign fromJson(Map<String, dynamic> json) => Sign.fromJson(json);
}
