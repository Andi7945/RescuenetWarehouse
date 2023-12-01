import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/routes.dart';

import '../../models/container_options.dart';
import '../../models/rescue_container.dart';
import '../../models/sequential_build.dart';

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
          _textField("name", _nameController),
          _textField("description", _descriptionController),
          _dropdownWithEdit(
              "container type",
              routeEditContainerTypes,
              _containerTypeController,
              widget._containerOptions.types
                  .map((e) => DropdownMenuEntry(value: e.id, label: e.name))),
          _sequentialBuildDropdown(),
          _dropdownWithEdit(
              "module destination",
              routeEditModuleDestinations,
              _moduleDestinationController,
              widget._containerOptions.moduleDestinations
                  .map((e) => DropdownMenuEntry(value: e.id, label: e.name))),
          _dropdownWithEdit(
              "current location",
              routeEditCurrentLocations,
              _currentLocationController,
              widget._containerOptions.currentLocations
                  .map((e) => DropdownMenuEntry(value: e.id, label: e.name)))
        ]));
  }

  _textField(String label, TextEditingController controller) => ListTile(
      title: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
          ),
          onChanged: (text) => _sendChangesToStore()));

  _sequentialBuildDropdown() => ListTile(
      title: DropdownMenu(
          initialSelection: _sequentialBuildController.value,
          onSelected: (String? value) {
            var v = value;
            if (v != null) {
              _sequentialBuildController.value = v;
            }
          },
          label: const Text(
            "sequential build",
            overflow: TextOverflow.ellipsis,
          ),
          dropdownMenuEntries: widget._containerOptions.sequentialBuilds
              .map(
                  (e) => DropdownMenuEntry(value: e.name, label: e.displayName))
              .toList()));

  _dropdownWithEdit(
          String labelText,
          String routeName,
          ValueNotifier<String?> notifier,
          Iterable<DropdownMenuEntry<String?>> entries) =>
      ListTile(
          title: DropdownMenu<String?>(
              initialSelection: notifier.value,
              onSelected: (String? value) {
                notifier.value = value;
              },
              label: Text(
                labelText,
                overflow: TextOverflow.ellipsis,
              ),
              dropdownMenuEntries: entries.toList()),
          trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(context, routeName)));

  _sendChangesToStore() {
    var changedContainer = widget._container.value.copyWith(
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
