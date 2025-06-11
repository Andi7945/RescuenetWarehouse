import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';

import '../../models/rescue_container.dart';
import '../../models/sequential_build.dart';

class ContainerEditPage extends river.ConsumerStatefulWidget {
  final ValueNotifier<RescueContainer> _container;

  ContainerEditPage(this._container);

  @override
  river.ConsumerState createState() => _ContainerEditPageState();
}

class _ContainerEditPageState extends river.ConsumerState<ContainerEditPage> {
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
          _containerTypeDropdown(),
          _sequentialBuildDropdown(),
          _moduleDestinationDropdown(),
          _currentLocationsDropdown()
        ]));
  }

  _containerTypeDropdown() {
    var options = ref.watch(containerTypesNotifierProvider);
    return _dropdownWithEdit(
        "container type",
        routeEditContainerTypes,
        _containerTypeController,
        options.map((e) => DropdownMenuEntry(value: e.id, label: e.name)));
  }

  _moduleDestinationDropdown() {
    var dests = ref.watch(moduleDestinationsNotifierProvider);
    return _dropdownWithEdit(
        "module destination",
        routeEditModuleDestinations,
        _moduleDestinationController,
        dests.map((e) => DropdownMenuEntry(value: e.id, label: e.name)));
  }

  _currentLocationsDropdown() {
    var locs = ref.watch(currentLocationsNotifierProvider);
    return _dropdownWithEdit(
        "current location",
        routeEditCurrentLocations,
        _currentLocationController,
        locs.map((e) => DropdownMenuEntry(value: e.id, label: e.name)));
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
          dropdownMenuEntries: SequentialBuild.values
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
      : ref.read(containerTypesNotifierProvider).firstWhere(
          (element) => element.id == _containerTypeController.value);

  _destination() => _moduleDestinationController.value == null
      ? null
      : ref.read(moduleDestinationsNotifierProvider).firstWhere(
          (element) => element.id == _moduleDestinationController.value);

  _location() => _currentLocationController.value == null
      ? null
      : ref.read(currentLocationsNotifierProvider).firstWhere(
          (element) => element.id == _currentLocationController.value);
}
