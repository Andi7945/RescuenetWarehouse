import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'container_options.dart';
import 'rescue_container.dart';
import 'sequential_build.dart';

class ContainerEditPage extends StatefulWidget {
  final ValueNotifier<RescueContainer> _container;
  final ContainerOptions _containerOptions;

  ContainerEditPage(this._container, this._containerOptions);

  @override
  State createState() => _ContainerEditPageState();
}

class _ContainerEditPageState extends State<ContainerEditPage> {
  final TextEditingController _nameController = TextEditingController();
  late ValueNotifier<String> _containerTypeController;
  late ValueNotifier<String> _moduleDestinationController;
  late ValueNotifier<String> _currentLocationController;
  late ValueNotifier<String> _sequentialBuildController;

  @override
  void initState() {
    super.initState();
    var container = widget._container.value;

    var name = container.name;
    if (name != null) {
      _nameController.text = name;
    }
    _containerTypeController = ValueNotifier(container.type.name);
    _moduleDestinationController =
        ValueNotifier(container.moduleDestination ?? "");
    _currentLocationController = ValueNotifier(container.currentLocation ?? "");
    _sequentialBuildController = ValueNotifier(container.sequentialBuild.name);

    for (var controller in [
      _containerTypeController,
      _moduleDestinationController,
      _currentLocationController,
      _sequentialBuildController,
      _nameController
    ]) {
      controller.addListener(() {
        _sendChangesToStore();
      });
    }
  }

  @override
  Widget build(BuildContext context) => _body();

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: ListView(children: [
          _tile(
              "Name",
              TextField(
                  controller: _nameController,
                  onChanged: (text) => _sendChangesToStore())),
          _editableTile(
              "Type of container",
              RescueDropdownButton(
                  widget._containerOptions.types.map((e) => e.name).toList(),
                  _containerTypeController),
              routeEditContainerTypes),
          _tile(
              "Sequential build",
              RescueDropdownButton(widget._containerOptions.sequentialBuilds,
                  _sequentialBuildController)),
          _editableTile(
              "Module destination",
              RescueDropdownButton(widget._containerOptions.moduleDestinations,
                  _moduleDestinationController),
              routeEditModuleDestinations),
          _editableTile(
              "Current location",
              RescueDropdownButton(widget._containerOptions.currentLocations,
                  _currentLocationController),
              routeEditCurrentLocations),
        ]));
  }

  _tile(String label, Widget child) =>
      ListTile(leading: SizedBox(width: 160, child: Text(label)), title: child);

  _editableTile(String label, Widget child, String routeName) => ListTile(
        leading: SizedBox(width: 160, child: Text(label)),
        title: child,
        trailing: InkWell(
            onTap: () => Navigator.pushNamed(context, routeName),
            child: RescueImage('/edit_icon.png')),
      );

  _sendChangesToStore() {
    var changedContainer = RescueContainer(
        widget._container.value.id,
        _nameController.text,
        widget._containerOptions.types.firstWhere(
            (element) => element.name == _containerTypeController.value),
        widget._container.value.imagePath,
        SequentialBuild.values.firstWhere(
            (element) => element.name == _sequentialBuildController.value),
        _moduleDestinationController.value,
        _currentLocationController.value);
    widget._container.value = changedContainer;
  }
}
