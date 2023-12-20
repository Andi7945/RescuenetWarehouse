import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/container_filter.dart';
import 'package:rescuenet_warehouse/filter_fields.dart';
import 'package:rescuenet_warehouse/ui/rescue_dropdown_button.dart';

class RescueFilterDropdown extends StatefulWidget {
  final ValueNotifier<ContainerFilter> valueNotifier;

  RescueFilterDropdown(this.valueNotifier);

  @override
  State createState() => _RescueFilterDropdownState();
}

class _RescueFilterDropdownState extends State<RescueFilterDropdown> {
  late final TextEditingController _controller;
  late final ValueNotifier<String> _o;

  @override
  void initState() {
    super.initState();

    _o = ValueNotifier(widget.valueNotifier.value.field.name);
    _controller =
        TextEditingController(text: widget.valueNotifier.value.value ?? "");

    _o.addListener(() {
      widget.valueNotifier.value = ContainerFilter(
          FilterField.values.firstWhere((v) => v.name == _o.value),
          _controller.text);
    });

    _controller.addListener(() {
      widget.valueNotifier.value =
          widget.valueNotifier.value.withNewValue(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        SizedBox(
            width: 300,
            child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 24.0))),
        RescueDropdownButton(
            _filterOptions, _o, Theme.of(context).textTheme.titleLarge)
      ]);

  Map<String, String> get _filterOptions => Map.fromEntries(
      FilterField.values.map((e) => MapEntry(e.name, e.displayName)));
}
