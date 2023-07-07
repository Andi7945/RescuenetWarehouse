import 'package:flutter/material.dart';

import 'container_type.dart';

class RescueDropdownButton extends StatefulWidget {
  List<String> options;
  String? initial;

  RescueDropdownButton(this.options, [this.initial]);

  RescueDropdownButton.custom(List<ContainerType> types, [String? initial])
      : this(types.map((e) => e.name).toList(), initial);

  @override
  State createState() => _RescueDropdownButtonState();
}

class _RescueDropdownButtonState extends State<RescueDropdownButton> {
  String? currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initial ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: widget.options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      value: currentValue,
      onChanged: (String? value) {
        setState(() {
          currentValue = value;
        });
      },
    );
  }
}
