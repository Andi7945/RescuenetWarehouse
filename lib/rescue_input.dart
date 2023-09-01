import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RescueInputText extends StatelessWidget {
  ValueChanged<String> onChange;
  String? initial;
  String? hintText;
  int? maxLines;

  RescueInputText(
      {required this.initial,
      required this.onChange,
      this.hintText,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    var controller = _buildController();
    return TextFormField(
        maxLines: maxLines ?? 1,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
            hintText: hintText ?? "Insert new value here",
            hintStyle: const TextStyle(fontSize: 24)),
        controller: controller);
  }

  _buildController() {
    var controller = TextEditingController(text: initial);
    controller.addListener(() {
      onChange(controller.text);
    });
  }
}
