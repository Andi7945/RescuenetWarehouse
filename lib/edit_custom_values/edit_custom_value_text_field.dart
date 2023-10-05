import 'package:flutter/material.dart';

class EditCustomValueTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChange;

  EditCustomValueTextField(this.controller, [this.onChange]);

  @override
  State createState() => _EditCustomValueTextFieldState();
}

class _EditCustomValueTextFieldState extends State<EditCustomValueTextField> {
  bool _focussed = false;

  @override
  Widget build(BuildContext context) => TextField(
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
            hintText: "Insert new value here",
            hintStyle: TextStyle(fontSize: 16)),
        controller: widget.controller,
        onTap: () {
          _focussed = true;
        },
        onTapOutside: (_) {
          if (widget.onChange != null && _focussed) {
            _focussed = false;
            widget.onChange!(widget.controller.text);
          }
        },
      );
}
