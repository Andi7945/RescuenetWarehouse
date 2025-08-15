import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';

import '../../models/rescue_container.dart';
import '../../models/sequential_build.dart';
import '../../models/container_dao.dart';

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
    final asyncOptions = ref.watch(containerTypesAsyncProvider);
    return AsyncValueBuilder(
      value: asyncOptions,
      data: (options) => _dropdownWithEdit(
          "container type",
          routeEditContainerTypes,
          _containerTypeController,
          options.map((e) => DropdownMenuEntry(value: e.id, label: e.name))),
      loading: () => ListTile(
        title: DropdownMenu<String?>(
          enabled: false,
          label: const Text("container type"),
          dropdownMenuEntries: const [],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.pushNamed(context, routeEditContainerTypes),
        ),
      ),
    );
  }

  _moduleDestinationDropdown() {
    final asyncDests = ref.watch(moduleDestinationsAsyncProvider);
    return AsyncValueBuilder(
      value: asyncDests,
      data: (dests) => _dropdownWithEdit(
          "module destination",
          routeEditModuleDestinations,
          _moduleDestinationController,
          dests.map((e) => DropdownMenuEntry(value: e.id, label: e.name))),
      loading: () => ListTile(
        title: DropdownMenu<String?>(
          enabled: false,
          label: const Text("module destination"),
          dropdownMenuEntries: const [],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.pushNamed(context, routeEditModuleDestinations),
        ),
      ),
    );
  }

  _currentLocationsDropdown() {
    final asyncLocs = ref.watch(currentLocationsAsyncProvider);
    return AsyncValueBuilder(
      value: asyncLocs,
      data: (locs) => _dropdownWithEdit(
          "current location",
          routeEditCurrentLocations,
          _currentLocationController,
          locs.map((e) => DropdownMenuEntry(value: e.id, label: e.name))),
      loading: () => ListTile(
        title: DropdownMenu<String?>(
          enabled: false,
          label: const Text("current location"),
          dropdownMenuEntries: const [],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.pushNamed(context, routeEditCurrentLocations),
        ),
      ),
    );
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

  Future<void> _sendChangesToStore() async {
    var changedContainer = widget._container.value.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        type: _type(),
        sequentialBuild: SequentialBuild.values.firstWhere(
            (element) => element.name == _sequentialBuildController.value),
        moduleDestination: _destination(),
        currentLocation: _location());
    widget._container.value = changedContainer;
    
    // Persist changes to database with loading state
    try {
      await ref.read(dataOperationsNotifierProvider.notifier)
          .updateContainer(ContainerDao.fromContainer(changedContainer));
    } catch (error) {
      // Error will be handled by DataOperationsNotifier and shown in UI
      // Reset UI state to previous value on error
      if (mounted) {
        setState(() {
          _nameController.text = widget._container.value.name;
          _descriptionController.text = widget._container.value.description ?? "";
          _containerTypeController.value = widget._container.value.type?.id;
          _moduleDestinationController.value = widget._container.value.moduleDestination?.id;
          _currentLocationController.value = widget._container.value.currentLocation?.id;
          _sequentialBuildController.value = widget._container.value.sequentialBuild.name;
        });
      }
      rethrow;
    }
  }

  _type() {
    if (_containerTypeController.value == null) return null;
    final containerTypes = ref.read(containerTypesAsyncProvider);
    return containerTypes.when(
      data: (types) => types.firstWhere(
          (element) => element.id == _containerTypeController.value),
      loading: () => null,
      error: (_, __) => null,
    );
  }

  _destination() {
    if (_moduleDestinationController.value == null) return null;
    final moduleDestinations = ref.read(moduleDestinationsAsyncProvider);
    return moduleDestinations.when(
      data: (destinations) => destinations.firstWhere(
          (element) => element.id == _moduleDestinationController.value),
      loading: () => null,
      error: (_, __) => null,
    );
  }

  _location() {
    if (_currentLocationController.value == null) return null;
    final currentLocations = ref.read(currentLocationsAsyncProvider);
    return currentLocations.when(
      data: (locations) => locations.firstWhere(
          (element) => element.id == _currentLocationController.value),
      loading: () => null,
      error: (_, __) => null,
    );
  }
}
