import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RescueInputTextDirect extends StatefulWidget {
  ValueChanged<String> onChange;
  String? initial;
  String? hintText;
  String? label;
  int? maxLines;
  double? fontSize;

  RescueInputTextDirect({
    required this.initial,
    required this.onChange,
    this.label,
    this.hintText,
    this.maxLines,
    this.fontSize,
  });

  @override
  State createState() => _RescueInputTextDirectState();
}

class _RescueInputTextDirectState extends State<RescueInputTextDirect> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    _controller.text = widget.initial ?? "";
    _controller.addListener(_printLatestValue);
    _controller.addListener(() => widget.onChange(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines ?? 1,
      style: TextStyle(fontSize: widget.fontSize ?? 16),
      decoration: InputDecoration(
        hintText: widget.hintText ?? "Insert new value here",
        hintStyle: TextStyle(fontSize: widget.fontSize ?? 16),
        labelText: widget.label,
      ),
      controller: _controller,
    );
  }

  void _printLatestValue() {
    final text = _controller.text;
    print('Second text field: $text (${text.characters.length})');
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
