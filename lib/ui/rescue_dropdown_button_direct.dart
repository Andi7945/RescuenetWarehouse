import 'package:flutter/material.dart';

class RescueDropdownButtonDirect<T> extends StatelessWidget {
  Map<T, String> optionToDisplayName;
  T currentOption;
  Function(T?) onChange;

  RescueDropdownButtonDirect(
    this.optionToDisplayName,
    this.currentOption,
    this.onChange,
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      style: Theme.of(context).textTheme.titleMedium,
      items: optionToDisplayName.entries.map(_createItem).toList(),
      value: currentOption,
      onChanged: onChange,
    );
  }

  DropdownMenuItem<T> _createItem(MapEntry<T, String> optionToDisplayName) =>
      DropdownMenuItem<T>(
        value: optionToDisplayName.key,
        child: Text(optionToDisplayName.value),
      );
}
