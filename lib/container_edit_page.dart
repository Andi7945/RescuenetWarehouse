import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/data_mocks.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'rescue_container.dart';
import 'sequential_build.dart';

class ContainerEditPage extends StatefulWidget {
  RescueContainer _container;

  ContainerEditPage(this._container);

  @override
  State createState() => _ContainerEditPageState();
}

class _ContainerEditPageState extends State<ContainerEditPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var name = widget._container.name;
    if (name != null) {
      _nameController.text = name;
    }
  }

  @override
  Widget build(BuildContext context) => _body();

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: ListView(children: [
          _tile("Name", TextField(controller: _nameController)),
          _editableTile(
              "Type of container",
              RescueDropdownButton.custom(
                  container_options_type, widget._container.type.name),
              "containerTypes"),
          _tile(
              "Sequential build",
              RescueDropdownButton(
                  SequentialBuild.values.map((e) => e.name).toList(),
                  widget._container.sequentialBuild.name)),
          _editableTile(
              "Module destination",
              RescueDropdownButton(container_options_module_destination,
                  widget._container.moduleDestination),
              "destinations"),
          _editableTile(
              "Current location",
              RescueDropdownButton(container_options_current_location,
                  widget._container.currentLocation),
              "locations"),
        ]));
  }

  _tile(String label, Widget child) =>
      ListTile(leading: SizedBox(width: 160, child: Text(label)), title: child);

  _editableTile(String label, Widget child, String type) => ListTile(
        leading: SizedBox(width: 160, child: Text(label)),
        title: child,
        trailing: InkWell(
            onTap: () => Navigator.pushNamed(context, routeEditCustomValues,
                arguments: type),
            child: RescueImage('/edit_icon.png')),
      );
}
