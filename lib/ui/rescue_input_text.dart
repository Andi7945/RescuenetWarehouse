import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rescuenet_warehouse/ui/focus_field.dart';

class RescueInputText extends StatefulWidget {
  ValueChanged<String> onChange;
  String? initial;
  String? hintText;
  String? label;
  int? maxLines;
  double? fontSize;

  RescueInputText(
      {required this.initial,
      required this.onChange,
      this.label,
      this.hintText,
      this.maxLines,
      this.fontSize});

  @override
  State createState() => _RescueInputTextState();
}

class _RescueInputTextState extends State<RescueInputText> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = widget.initial ?? "";
    return FocusField(
        onLostFocus: () {
          if (widget.initial != _controller.text) {
            print("New value. Go change!");
            widget.onChange(_controller.text);
          } else {
            print("Lost focus without new values. No change please.");
          }
        },
        child: TextFormField(
            maxLines: widget.maxLines ?? 1,
            style: TextStyle(fontSize: widget.fontSize ?? 16),
            decoration: InputDecoration(
                hintText: widget.hintText ?? "Insert new value here",
                hintStyle: TextStyle(fontSize: widget.fontSize ?? 16),
                labelText: widget.label),
            controller: _controller));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
