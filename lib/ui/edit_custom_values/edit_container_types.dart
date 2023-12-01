import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/proxy_container_type_usage.dart';
import 'package:rescuenet_warehouse/main.dart';

import '../../models/container_type.dart';
import '../rescue_pickable_image.dart';
import '../rescue_table.dart';
import '../rescue_navigation_drawer.dart';
import 'edit_custom_value_delete_button.dart';
import 'edit_custom_value_text_field.dart';
import '../../stores.dart';

class EditContainerTypes extends StatefulWidget {
  @override
  State createState() => _EditContainerTypesState();
}

class _EditContainerTypesState extends State<EditContainerTypes> {
  final TextEditingController _addControllerName = TextEditingController();
  final TextEditingController _addControllerMeasurements =
      TextEditingController();
  final TextEditingController _addControllerEmptyWeight =
      TextEditingController();
  final ValueNotifier<String?> _imagePathNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Container types")),
        drawer: RescueNavigationDrawer(),
        body: _body());
  }

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<ContainerTypeUsage>(
            builder: (ctx, usages, _) => _table(usages.typesWithUsages)));
  }

  Widget _table(Map<ContainerType, Set<String>> currentTypes) => RescueTable(
      const ["Name", "Image", "Empty weight", "Measurements", ""],
      [..._rows(currentTypes), _addingRow()],
      const {});

  List<TableRow> _rows(Map<ContainerType, Set<String>> currentTypes) =>
      currentTypes.entries.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(MapEntry<ContainerType, Set<String>> type) =>
      TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _textField(
                type.key.name, (v) => _change(type.key.copyWith(name: v)))),
        RescuePickableImage(
          type.key.imagePath,
          (path) => _change(type.key.copyWith(imagePath: path)),
          90,
          80.89,
        ),
        _textField(
            type.key.emptyWeight.toStringAsFixed(1),
            (v) => _change(
                type.key.copyWith(emptyWeight: double.tryParse(v) ?? 0.0))),
        _textField(type.key.measurements,
            (v) => _change(type.key.copyWith(measurements: v))),
        EditCustomValueDeleteButton(type.value, () {
          Provider.of<StoreContainerTypes>(context, listen: false)
              .remove(type.key);
        })
      ]);

  _textField(String old, ValueChanged<String>? onChange) {
    return EditCustomValueTextField(TextEditingController(text: old), onChange);
  }

  _change(ContainerType type) =>
      Provider.of<StoreContainerTypes>(context, listen: false).upsert(type);

  TableRow _addingRow() => TableRow(children: [
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
        _btnAdd()
      ]);

  _leftPadded(Widget w) =>
      Padding(padding: const EdgeInsets.only(left: 20), child: w);

  _btnAdd() => IconButton(
      onPressed: () {
        Provider.of<StoreContainerTypes>(context, listen: false).upsert(
            ContainerType(
                id: uuid.v4(),
                name: _addControllerName.text,
                imagePath: _imagePathNotifier.value,
                emptyWeight:
                    double.tryParse(_addControllerEmptyWeight.text) ?? 0.0,
                measurements: _addControllerMeasurements.text));
        _addControllerName.clear();
        _addControllerEmptyWeight.clear();
        _addControllerMeasurements.clear();
      },
      icon: const Icon(Icons.add));
}
