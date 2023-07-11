import 'package:flutter/material.dart';

import 'container_type.dart';

class RescueDropdownButton extends StatelessWidget {
  List<String> options;
  ValueNotifier<String> valueNotifier;

  RescueDropdownButton(this.options, this.valueNotifier);

  RescueDropdownButton.custom(
      List<ContainerType> types, ValueNotifier<String> vn)
      : this(
            types.map((e) => e.name).toList(),
            // (s) => onValueChanged(types.firstWhere((type) => type.name == s)),
            vn);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      value: valueNotifier.value,
      onChanged: (String? value) {
        valueNotifier.value = value!;
      },
    );
  }
}
