import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/menu_option.dart';

import '../container_type.dart';
import '../menu.dart';
import '../rescue_pickable_image.dart';
import '../rescue_table.dart';
import '../rescue_text.dart';
import 'edit_custom_value_delete_button.dart';
import 'edit_custom_value_text_field.dart';
import '../stores.dart';

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
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Menu(MenuOption.containerOverview),
      Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 24),
          child: RescueText.headline("Edit container types")),
      Expanded(child: _body())
    ]));
  }

  _body() {
    return Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Consumer<StoreContainerTypes>(
            builder: (ctx, store, _) => _table(store.all)));
  }

  Widget _table(List<ContainerType> currentTypes) => RescueTable(
      const ["Name", "Image", "Empty weight", "Measurements", ""],
      [..._rows(currentTypes), _addingRow()],
      const {});

  List<TableRow> _rows(List<ContainerType> currentTypes) =>
      currentTypes.map<TableRow>(_buildRow).toList();

  TableRow _buildRow(ContainerType type) => TableRow(children: [
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _textField(type.name, (v) => _change(type: type, name: v))),
        RescuePickableImage(
          type.imagePath,
          (path) => _change(type: type, imagePath: path),
          90,
          80.89,
        ),
        _textField(type.emptyWeight.toStringAsFixed(1),
            (v) => _change(type: type, emptyWeight: double.tryParse(v))),
        _textField(
            type.measurements, (v) => _change(type: type, measurements: v)),
        EditCustomValueDeleteButton(null, () {
          Provider.of<StoreContainerTypes>(context, listen: false).remove(type);
        })
      ]);

  _textField(String old, ValueChanged<String>? onChange) {
    return EditCustomValueTextField(TextEditingController(text: old), onChange);
  }

  _change(
          {required ContainerType type,
          String? name,
          String? imagePath,
          String? measurements,
          double? emptyWeight}) =>
      Provider.of<StoreContainerTypes>(context, listen: false).upsert(
          ContainerType.from(
              type: type,
              imagePath: imagePath,
              emptyWeight: emptyWeight,
              name: name,
              measurements: measurements));

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

  _btnAdd() => TextButton(
      onPressed: () {
        Provider.of<StoreContainerTypes>(context, listen: false).upsert(
            ContainerType(
                uuid.v4(),
                _addControllerName.text,
                _imagePathNotifier.value,
                double.tryParse(_addControllerEmptyWeight.text) ?? 0.0,
                _addControllerMeasurements.text));
        _addControllerName.clear();
        _addControllerEmptyWeight.clear();
        _addControllerMeasurements.clear();
      },
      child: const RescueText(24, '+', fontWeight: FontWeight.w700));
}
