import 'package:flutter/material.dart';

class RescueTextField extends StatefulWidget {
  ValueChanged<String> onChange;
  String? initial;
  String label;
  int? maxLines;

  RescueTextField(
      {required this.initial,
      required this.onChange,
      required this.label,
      this.maxLines});

  @override
  State createState() => _RescueTextFieldState();
}

class _RescueTextFieldState extends State<RescueTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = widget.initial ?? "";
    return TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
        ),
        onChanged: (text) => widget.onChange(_controller.text));
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }
}
