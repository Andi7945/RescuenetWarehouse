import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RescueInputText extends StatefulWidget {
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
  State createState() => _RescueInputTextState();
}

class _RescueInputTextState extends State<RescueInputText> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = widget.initial ?? "";
    return TextFormField(
        maxLines: widget.maxLines ?? 1,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
            hintText: widget.hintText ?? "Insert new value here",
            hintStyle: const TextStyle(fontSize: 24)),
        controller: _controller,
        onChanged: widget.onChange);
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }
}
