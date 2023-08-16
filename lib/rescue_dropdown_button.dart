import 'package:flutter/material.dart';

class RescueDropdownButton<T> extends StatelessWidget {
  Map<T, String> optionToDisplayName;
  ValueNotifier<T?> valueNotifier;

  RescueDropdownButton(this.optionToDisplayName, this.valueNotifier);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: optionToDisplayName.entries.map(_createItem).toList(),
      value: valueNotifier.value,
      onChanged: (T? value) {
        valueNotifier.value = value;
      },
    );
  }

  DropdownMenuItem<T> _createItem(MapEntry<T, String> optionToDisplayName) =>
      DropdownMenuItem<T>(
        value: optionToDisplayName.key,
        child: Text(optionToDisplayName.value),
      );
}
