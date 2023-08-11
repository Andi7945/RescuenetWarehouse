import 'package:flutter/material.dart';

import 'container_type.dart';

class RescueDropdownButton extends StatelessWidget {
  Map<String, String> optionToDisplayName;
  ValueNotifier<String> valueNotifier;

  RescueDropdownButton(this.optionToDisplayName, this.valueNotifier);

  RescueDropdownButton.custom(
      List<ContainerType> types, ValueNotifier<String> vn)
      : this(
            Map.fromEntries(types.map((e) => MapEntry(e.id, e.name))),
            // (s) => onValueChanged(types.firstWhere((type) => type.name == s)),
            vn);

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
