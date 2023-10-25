import 'package:flutter/material.dart';

import 'rescue_container.dart';
import 'rescue_table.dart';
import 'rescue_text.dart';

class ExportPageTable extends StatelessWidget {
  final List<ContainerPrintingOptions> options;
  final Function(ContainerPrintingOptions) fnAdjustOption;
  final Function() printLabels;
  final Function() printPackingList;
  final Function() printSafetyDatasheets;

  ExportPageTable(this.options, this.fnAdjustOption, this.printPackingList,
      this.printLabels, this.printSafetyDatasheets);

  @override
  Widget build(BuildContext context) {
    return RescueTable(_headline, [_printButtonRow(), ..._rows()], const {});
  }

  final _headline = [
    "Name",
    "Deploy",
    "Print label",
    "Print packing list",
    "Print safety datasheet"
  ];

  TableRow _printButtonRow() => TableRow(children: [
        Container(),
        Container(),
        _printIcon(printLabels),
        _printIcon(printPackingList),
        _printIcon(printSafetyDatasheets)
      ]);

  Widget _printIcon(Function() onClick) => Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
          onTap: onClick, child: const Icon(Icons.print_outlined, size: 48.0)));

  List<TableRow> _rows() => options.map(_single).toList();

  TableRow _single(ContainerPrintingOptions option) => TableRow(children: [
        RescueText.slim(option.container.printName),
        _checkbox(option.container.toDeploy, null),
        _checkbox(option.printLabel, (v) {
          fnAdjustOption(ContainerPrintingOptions.from(
              options: option, printLabel: v ?? false));
        }),
        _checkbox(option.printPackingList, (v) {
          fnAdjustOption(ContainerPrintingOptions.from(
              options: option, printPackingList: v ?? false));
        }),
        _checkbox(option.printSafetyDatasheet, (v) {
          fnAdjustOption(ContainerPrintingOptions.from(
              options: option, printSafetyDatasheet: v ?? false));
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

  ContainerPrintingOptions.from(
      {required ContainerPrintingOptions options,
      bool? printLabel,
      bool? printPackingList,
      bool? printSafetyDatasheet})
      : container = options.container,
        printLabel = printLabel ?? options.printLabel,
        printPackingList = printPackingList ?? options.printPackingList,
        printSafetyDatasheet =
            printSafetyDatasheet ?? options.printSafetyDatasheet;
}
