import 'package:flutter/material.dart';

import 'rescue_container.dart';
import 'rescue_table.dart';
import 'rescue_text.dart';

class ExportPageTable extends StatefulWidget {
  final List<RescueContainer> containers;

  ExportPageTable(this.containers);

  @override
  State createState() => _ExportPageTableState();
}

class _ExportPageTableState extends State<ExportPageTable> {
  final List<ContainerPrintingOptions> options = [];

  @override
  Widget build(BuildContext context) {
    return RescueTable(_headline, _rows(), {});
  }

  @override
  void initState() {
    super.initState();

    options.addAll(widget.containers.map((e) => ContainerPrintingOptions(e)));
  }

  final _headline = [
    "Name",
    "Deploy",
    "Print label",
    "Print packing list",
    "Print safety datasheet"
  ];

  List<TableRow> _rows() => options.map(_single).toList();

  TableRow _single(ContainerPrintingOptions option) => TableRow(children: [
        RescueText.normal(option.container.name),
        _checkbox(option.container.toDeploy, null),
        _checkbox(option.printLabel, (v) {
          setState(() {
            option.printLabel = v ?? false;
          });
        }),
        _checkbox(option.printPackingList, (v) {
          setState(() {
            option.printPackingList = v ?? false;
          });
        }),
        _checkbox(option.printSafetyDatasheet, (v) {
          setState(() {
            option.printSafetyDatasheet = v ?? false;
          });
        })
      ]);

  Widget _checkbox(bool value, ValueChanged<bool?>? onChanged) => Align(
      alignment: Alignment.centerLeft,
      child: Transform.scale(
          scale: 2, child: Checkbox(value: value, onChanged: onChanged)));
}

class ContainerPrintingOptions {
  final RescueContainer container;
  bool printLabel = false;
  bool printPackingList = false;
  bool printSafetyDatasheet = false;

  ContainerPrintingOptions(this.container);
}