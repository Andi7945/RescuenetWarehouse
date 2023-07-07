import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/data_mocks.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';

import 'menu.dart';
import 'rescue_container.dart';

class ContainerEditPage extends StatefulWidget {
  RescueContainer _container;

  ContainerEditPage(this._container);

  @override
  State createState() => _ContainerEditPageState();
}

class _ContainerEditPageState extends State<ContainerEditPage> {
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    var name = widget._container.name;
    if (name != null) {
      _nameController.text = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Menu(), Expanded(child: _body())]));
  }

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: ListView(children: [
          _tile("Name", TextField(controller: _nameController)),
          _tile(
              "Type of container",
              RescueDropdownButton.custom(
                  container_options_type, widget._container.type.name)),
          _tile(
              "Sequential build",
              RescueDropdownButton(container_options_sequential_build,
                  widget._container.sequentialBuild.name)),
          _tile(
              "Module destination",
              RescueDropdownButton(container_options_module_destination,
                  widget._container.moduleDestination)),
          _tile(
              "Current location",
              RescueDropdownButton(container_options_current_location,
                  widget._container.currentLocation)),
        ]));
  }

  _tile(String label, Widget child) => ListTile(
        leading: SizedBox(width: 160, child: Text(label)),
        title: child,
      );
}
