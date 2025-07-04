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
  int? _lastAmount;

  @override
  Widget build(BuildContext context) {
    // Only update controller text if the amount actually changed
    if (_lastAmount != widget.amount) {
      _lastAmount = widget.amount;
      _controller.text = "${widget.amount}";
    }
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
      // Prevent negative amounts and extremely large values
      if (newAmount < 0) {
        newAmount = 0;
        _controller.text = "0";
      } else if (newAmount > 99999) {
        newAmount = 99999;
        _controller.text = "99999";
      }
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
