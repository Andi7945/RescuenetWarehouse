import 'package:flutter/material.dart';

class EditCustomValueTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChange;

  EditCustomValueTextField(this.controller, [this.onChange]);

  @override
  Widget build(BuildContext context) => TextField(
        style: const TextStyle(fontSize: 24),
        decoration: const InputDecoration(
            hintText: "Insert new value here",
            hintStyle: TextStyle(fontSize: 24)),
        controller: controller,
        onTapOutside: (_) {
          if (onChange != null) onChange!(controller.text);
        },
      );
}
