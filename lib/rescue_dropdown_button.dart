import 'package:flutter/material.dart';

class RescueDropdownButton extends StatelessWidget {
  Map<String, String> optionToDisplayName;
  ValueNotifier<String?> valueNotifier;

  RescueDropdownButton(this.optionToDisplayName, this.valueNotifier);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: optionToDisplayName.entries.map(_createItem).toList(),
      value: valueNotifier.value,
      onChanged: (String? value) {
        valueNotifier.value = value!;
      },
    );
  }

  DropdownMenuItem<String> _createItem(
          MapEntry<String, String> optionToDisplayName) =>
      DropdownMenuItem<String>(
        value: optionToDisplayName.key,
        child: Text(optionToDisplayName.value),
      );
}
