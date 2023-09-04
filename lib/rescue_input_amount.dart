import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RescueInputAmount extends StatefulWidget {
  final Function(int) onChange;
  final int amount;

  const RescueInputAmount(
      {super.key, required this.onChange, required this.amount});

  @override
  State createState() => _RescueInputAmountState();
}

class _RescueInputAmountState extends State<RescueInputAmount> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = "${widget.amount}";
    return TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24),
        controller: _controller,
        onChanged: _onChange);
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  _onChange(String s) {
    var newAmount = int.tryParse(s);
    if (newAmount != null) {
      widget.onChange(newAmount);
    } else {
      print("could not parse int from new amount: $s");
    }
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
