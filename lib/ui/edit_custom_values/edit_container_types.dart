import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/state/container_type_usage_notifier.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';

import '../../models/container_type.dart';
import '../rescue_pickable_image.dart';
import '../rescue_table.dart';
import '../rescue_navigation_drawer.dart';
import '../../widgets/rescue_app_bar.dart';
import 'edit_custom_value_text_field.dart';

class EditContainerTypes extends river.ConsumerStatefulWidget {
  @override
  river.ConsumerState createState() => _EditContainerTypesState();
}

class _EditContainerTypesState extends river.ConsumerState<EditContainerTypes> {
  final TextEditingController _addControllerName = TextEditingController();
  final TextEditingController _addControllerMeasurements =
      TextEditingController();
  final TextEditingController _addControllerEmptyWeight =
      TextEditingController();
  final ValueNotifier<String?> _imagePathNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RescueAppBar(title: "Container types"),
      drawer: RescueNavigationDrawer(),
      body: _body(),
    );
  }

  _body() {
    var usageAsync = ref.watch(containerTypeUsageNotifierProvider);
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: usageAsync.when(
        data: (usage) => _table(usage),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading container types: $error'),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(containerTypeUsageNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _table(Map<ContainerType, Set<String>> currentTypes) => RescueTable(
    const ["Name", "Image", "Empty weight", "Measurements", ""],
    [..._rows(currentTypes), _addingRow()],
    const {},
  );

  List<TableRow> _rows(Map<ContainerType, Set<String>> currentTypes) =>
      currentTypes.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<ContainerType, Set<String>> type) => TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: _textField(
          type.key.name,
          (v) => _change(type.key.copyWith(name: v)),
        ),
      ),
      RescuePickableImage(
        type.key.imagePath,
        (path) => _change(type.key.copyWith(imagePath: path)),
        90,
        80.89,
      ),
      _textField(
        type.key.emptyWeight.toStringAsFixed(1),
        (v) =>
            _change(type.key.copyWith(emptyWeight: double.tryParse(v) ?? 0.0)),
      ),
      _textField(
        type.key.measurements,
        (v) => _change(type.key.copyWith(measurements: v)),
      ),
      DeleteButtonWithUsages(type.value, () {
        ref.read(containerTypesNotifierProvider.notifier).delete(type.key);
      }),
    ],
  );

  _textField(String old, ValueChanged<String>? onChange) {
    return EditCustomValueTextField(TextEditingController(text: old), onChange);
  }

  _change(ContainerType type) =>
      ref.read(containerTypesNotifierProvider.notifier).upsert(type);

  TableRow _addingRow() => TableRow(
    children: [
      _leftPadded(EditCustomValueTextField(_addControllerName)),
      RescuePickableImage(
        _imagePathNotifier.value,
        (path) => setState(() {
          _imagePathNotifier.value = path;
        }),
        90,
        80.89,
      ),
      EditCustomValueTextField(_addControllerEmptyWeight),
      EditCustomValueTextField(_addControllerMeasurements),
      _btnAdd(),
    ],
  );

  _leftPadded(Widget w) =>
      Padding(padding: const EdgeInsets.only(left: 20), child: w);

  _btnAdd() => IconButton(
    onPressed: () {
      var newType = ContainerType(
        id: uuid.v4(),
        name: _addControllerName.text,
        imagePath: _imagePathNotifier.value,
        emptyWeight: double.tryParse(_addControllerEmptyWeight.text) ?? 0.0,
        measurements: _addControllerMeasurements.text,
      );
      ref.read(containerTypesNotifierProvider.notifier).upsert(newType);
      _addControllerName.clear();
      _addControllerEmptyWeight.clear();
      _addControllerMeasurements.clear();
    },
    icon: const Icon(Icons.add),
  );
}
