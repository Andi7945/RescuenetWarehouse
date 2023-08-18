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
  late ValueNotifier<String?> _containerTypeController;
  late ValueNotifier<String?> _moduleDestinationController;
  late ValueNotifier<String?> _currentLocationController;
  late ValueNotifier<String> _sequentialBuildController;

  @override
  void initState() {
    super.initState();
    var container = widget._container.value;

    _nameController.text = container.name;
    _containerTypeController = ValueNotifier(container.type?.id);
    _moduleDestinationController =
        ValueNotifier(container.moduleDestination?.id);
    _currentLocationController = ValueNotifier(container.currentLocation?.id);
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    _containerTypeController.value = widget._container.value.type?.id;
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
                  Map.fromEntries(widget._containerOptions.types
                      .map((e) => MapEntry(e.id, e.name))),
                  _containerTypeController),
              routeEditContainerTypes),
          _tile(
              "Sequential build",
              RescueDropdownButton(
                  Map.fromEntries(widget._containerOptions.sequentialBuilds
                      .map((e) => MapEntry(e, e))),
                  _sequentialBuildController)),
          _editableTile(
              "Module destination",
              RescueDropdownButton(
                  Map.fromEntries(widget._containerOptions.moduleDestinations
                      .map((e) => MapEntry(e.id, e.name))),
                  _moduleDestinationController),
              routeEditModuleDestinations),
          _editableTile(
              "Current location",
              RescueDropdownButton(
                  Map.fromEntries(widget._containerOptions.currentLocations
                      .map((e) => MapEntry(e.id, e.name))),
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
    var changedContainer = RescueContainer.from(
        container: widget._container.value,
        name: _nameController.text,
        type: _type(),
        sequentialBuild: SequentialBuild.values.firstWhere(
            (element) => element.name == _sequentialBuildController.value),
        moduleDestination: _destination(),
        currentLocation: _location());
    widget._container.value = changedContainer;
  }

  _type() => _containerTypeController.value == null
      ? null
      : widget._containerOptions.types.firstWhere(
          (element) => element.id == _containerTypeController.value);

  _destination() => _moduleDestinationController.value == null
      ? null
      : widget._containerOptions.moduleDestinations.firstWhere(
          (element) => element.id == _moduleDestinationController.value);

  _location() => _currentLocationController.value == null
      ? null
      : widget._containerOptions.currentLocations.firstWhere(
          (element) => element.id == _currentLocationController.value);
}
