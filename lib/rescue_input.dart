import 'package:flutter/material.dart';

class RescueInput extends StatelessWidget {
  TextEditingController controller;
  ValueChanged<String>? onChange;
  String? hintText;

  RescueInput(this.controller, [this.onChange, this.hintText]);

  RescueInput.plain(String initial,
      [ValueChanged<String>? onChange, String? hintText])
      : this(controllerWithListener(initial, onChange), onChange, hintText);

  @override
  Widget build(BuildContext context) => TextField(
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
          hintText: hintText ?? "Insert new value here",
          hintStyle: const TextStyle(fontSize: 24)),
      controller: controller);
}

controllerWithListener(String initial, ValueChanged<String>? onChange) {
  var controller = TextEditingController(text: initial);
  controller.addListener(() {
    if (onChange != null) onChange(controller.text);
  });
  return controller;
}
