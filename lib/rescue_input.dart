import 'package:flutter/material.dart';

class RescueInput extends StatelessWidget {
  TextEditingController controller;
  ValueChanged<String>? onChange;
  String? hintText;

  RescueInput(this.controller, [this.onChange, this.hintText]);

  @override
  Widget build(BuildContext context) => TextField(
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
            hintText: hintText ?? "Insert new destination here",
            hintStyle: const TextStyle(fontSize: 24)),
        controller: controller,
        onTapOutside: (_) {
          if (onChange != null) {
            onChange!(controller.text);
          }
        },
      );
}
