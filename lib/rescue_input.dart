import 'package:flutter/material.dart';

class RescueInput extends StatefulWidget {
  ValueChanged<String>? onChange;
  String? initial;
  String? hintText;

  RescueInput(this.initial, this.onChange, [this.hintText]);

  @override
  State createState() => _RescueInputState();
}

class _RescueInputState extends State<RescueInput> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.initial ?? "";
    if (widget.onChange != null) {
      controller.addListener(() {
        widget.onChange!(controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) => TextField(
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
          hintText: widget.hintText ?? "Insert new value here",
          hintStyle: const TextStyle(fontSize: 24)),
      controller: controller);
}
