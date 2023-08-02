import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RescueInput extends StatefulWidget {
  ValueChanged<String>? onChange;
  String? initial;
  String? hintText;
  bool? digitsOnly;

  RescueInput(
      {required this.initial,
      required this.onChange,
      this.hintText,
      this.digitsOnly});

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
        if (controller.text != null && controller.text != "") {
          widget.onChange!(controller.text);
        } else {
          widget.onChange!("0");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: _buildInputFormatters(),
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
          hintText: widget.hintText ?? "Insert new value here",
          hintStyle: const TextStyle(fontSize: 24)),
      controller: controller);

  List<TextInputFormatter>? _buildInputFormatters() =>
      (widget.digitsOnly == true)
          ? [FilteringTextInputFormatter.digitsOnly]
          : [];

  String? numberValidator(String? value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }
}
