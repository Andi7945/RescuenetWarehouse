import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/printing/ui/export_actions.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import 'export_page_table.dart';

class ExportPageBody extends ConsumerStatefulWidget {
  final Map<RescueContainer, Map<Item, int>> containerWithItems;

  const ExportPageBody(this.containerWithItems, {super.key});

  @override
  ConsumerState<ExportPageBody> createState() => _ExportPageBodyState();
}

class _ExportPageBodyState extends ConsumerState<ExportPageBody> {
  final List<ContainerPrintingOptions> options = [];

  @override
  Widget build(BuildContext context) => _body();

  @override
  void initState() {
    super.initState();

    options.addAll(widget.containerWithItems.keys
        .where((element) => element.isReady)
        .map((e) => ContainerPrintingOptions(e))
        .toList());

    options.sort((a, b) => a.container.number.compareTo(b.container.number));
  }

  _body() => Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: ExportPageTable(options, _adjustOption, _sharePackingListPdf,
          _shareLabelPdf, _shareSafetyDatasheets));

  _adjustOption(ContainerPrintingOptions option) {
    var toAdjust =
        options.firstWhere((element) => element.container == option.container);
    setState(() {
      toAdjust.printPackingList = option.printPackingList;
      toAdjust.printSafetyDatasheet = option.printSafetyDatasheet;
      toAdjust.printLabel = option.printLabel;
    });
  }

  Future<void> _sharePackingListPdf() async {
    final toPrint = options
        .where((ele) => ele.printPackingList)
        .map((e) => e.container)
        .toList();
    final withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));

    await ExportActions.handlePackingLists(context, ref, withItems);
  }

  Future<void> _shareLabelPdf() async {
    final toPrint =
        options.where((ele) => ele.printLabel).map((e) => e.container).toList();
    final withItems = Map.fromEntries(widget.containerWithItems.entries
        .where((ele) => toPrint.contains(ele.key)));

    await ExportActions.handleLabels(context, ref, withItems);
  }

  Future<void> _shareSafetyDatasheets() async {
    final toPrint = options
        .where((ele) => ele.printSafetyDatasheet)
        .map((e) => e.container)
        .toList();
    final withItems = Map.fromEntries(
      widget.containerWithItems.entries.where((ele) => toPrint.contains(ele.key)),
    );

    await ExportActions.handleSafetyDatasheets(context, ref, withItems);
  }
}
