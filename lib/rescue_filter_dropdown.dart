import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';

import 'filter.dart';

class RescueFilterDropdown extends StatefulWidget {
  final ValueNotifier<Filter> valueNotifier;

  RescueFilterDropdown(this.valueNotifier);

  @override
  State createState() => _RescueFilterDropdownState();
}

class _RescueFilterDropdownState extends State<RescueFilterDropdown> {
  final _controller = TextEditingController();
  final _o = ValueNotifier(FilterField.containerName.name);

  @override
  void initState() {
    super.initState();

    _o.addListener(() {
      widget.valueNotifier.value = _currentFilter;
    });

    _controller.addListener(() {
      widget.valueNotifier.value = _currentFilter;
    });
  }

  get _currentFilter => Filter(
      FilterField.values.firstWhere((v) => v.name == _o.value),
      _controller.text);

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(width: 300, child: TextField(controller: _controller)),
        RescueDropdownButton(_filterOptions, _o)
      ]);

  Map<String, String> get _filterOptions => Map.fromEntries(
      FilterField.values.map((e) => MapEntry(e.name, e.displayName)));
}
