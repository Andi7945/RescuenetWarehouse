import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';
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
  final TextEditingController _descriptionController = TextEditingController();
  late ValueNotifier<String?> _containerTypeController;
  late ValueNotifier<String?> _moduleDestinationController;
  late ValueNotifier<String?> _currentLocationController;
  late ValueNotifier<String> _sequentialBuildController;

  @override
  void initState() {
    super.initState();
    var container = widget._container.value;

    _nameController.text = container.name;
    _descriptionController.text = container.description ?? "";
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
      _nameController,
      _descriptionController
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
          _tile("Number", RescueText.slim("${widget._container.value.number}")),
          _tile(
              "Description",
              TextField(
                  controller: _descriptionController,
                  onChanged: (text) => _sendChangesToStore())),
          _dropdownWithEdit(
              "Type of container",
              (co) => co.types.map((e) => MapEntry(e.id, e.name)),
              _containerTypeController,
              routeEditContainerTypes),
          _dropdown(
              "Sequential build",
              (co) => co.sequentialBuilds
                  .map((e) => MapEntry(e.name, e.displayName)),
              _sequentialBuildController),
          _dropdownWithEdit(
              "Module destination",
              (co) => co.moduleDestinations.map((e) => MapEntry(e.id, e.name)),
              _moduleDestinationController,
              routeEditModuleDestinations),
          _dropdownWithEdit(
              "Current location",
              (co) => co.currentLocations.map((e) => MapEntry(e.id, e.name)),
              _currentLocationController,
              routeEditCurrentLocations),
        ]));
  }

  _tile(String label, Widget child, [Widget? editBtn]) => ListTile(
      titleAlignment: ListTileTitleAlignment.center,
      leading: SizedBox(width: 160, child: Text(label)),
      title: child,
      trailing: editBtn);

  _dropdown(
          String label,
          Iterable<MapEntry<String, String>> Function(ContainerOptions) fn,
          ValueNotifier<String?> controller,
          [Widget? editBtn]) =>
      _tile(
          label,
          RescueDropdownButton(
              Map.fromEntries(fn(widget._containerOptions)), controller),
          editBtn);

  _dropdownWithEdit(
          String label,
          Iterable<MapEntry<String, String>> Function(ContainerOptions) fn,
          ValueNotifier<String?> controller,
          String routeName) =>
      _dropdown(
          label,
          fn,
          controller,
          InkWell(
              onTap: () => Navigator.pushNamed(context, routeName),
              child: RescueImage('/edit_icon.png')));

  _sendChangesToStore() {
    var changedContainer = RescueContainer.from(
        container: widget._container.value,
        name: _nameController.text,
        description: _descriptionController.text,
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
