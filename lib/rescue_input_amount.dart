import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RescueInputAmount extends StatefulWidget {
  final ValueNotifier<int> notifier;

  const RescueInputAmount({super.key, required this.notifier});

  @override
  State createState() => _RescueInputAmountState();
}

class _RescueInputAmountState extends State<RescueInputAmount> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: "${widget.notifier.value}");
    controller.addListener(() {
      _onChange(controller.text);
    });
    widget.notifier.addListener(() {
      controller.text = "${widget.notifier.value}";
    });
  }

  _onChange(String s) {
    var newAmount = int.tryParse(s);
    if (newAmount != null) {
      widget.notifier.value = newAmount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24),
        controller: controller);
  }

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
