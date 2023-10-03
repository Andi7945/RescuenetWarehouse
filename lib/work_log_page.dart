import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/container_visibility_service.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';
import 'package:rescuenet_warehouse/work_log_page_body_from_date.dart';
import 'package:rescuenet_warehouse/work_log_service.dart';

import 'modal_container_chooser.dart';

import 'package:intl/intl.dart';

import 'widget/rescue_navigation_drawer.dart';
import 'work_log_page_body_all.dart';

class WorkLogPage extends StatefulWidget {
  @override
  State createState() => _WorkLogPageState();
}

class _WorkLogPageState extends State<WorkLogPage> {
  final DateFormat formatter = DateFormat('MMM d, yyyy');
  DateTime? onlyFromDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Work log"), actions: [
          _allChangesButton(),
          _dateChooser()
        ]),
        drawer: RescueNavigationDrawer(),
        body: Consumer2<ContainerVisibilityService, WorkLogService>(
            builder: (ctxt, visibilityService, workLogService, _) {
          var withVisibility = visibilityService.containerWithVisible();
          return Column(children: [
            _padded(_btnRow(ctxt, withVisibility)),
            Expanded(child: _padded(_body(workLogService)))
          ]);
        }));
  }

  Widget _body(WorkLogService workLogService) => onlyFromDate == null
      ? WorkLogPageBodyAll(workLogService.byDateAndContainerName())
      : WorkLogPageBodyFromDate(
          onlyFromDate!, workLogService.fromDate(onlyFromDate!));

  _padded(Widget w) =>
      Padding(padding: const EdgeInsets.only(left: 40, right: 40), child: w);

  Widget _btnRow(
          BuildContext ctxt, Map<RescueContainer, bool> withVisibility) =>
      Wrap(alignment: WrapAlignment.spaceEvenly, children: [
        _btnChooseContainer(ctxt, withVisibility)
      ]);

  Widget _allChangesButton() => FilledButton(
      onPressed: () => setState(() {
            onlyFromDate = null;
          }),
      child: RescueText.slim("All"));

  Widget _dateChooser() => FilledButton(
      onPressed: () async {
        await _chooseNewDate();
      },
      child: RescueText.slim("from date"));

  Future<void> _chooseNewDate() async {
    var newDate = await _dialogBuilder(
        context, DateTime.now().subtract(const Duration(days: 7)));
    if (newDate != null) {
      setState(() {
        onlyFromDate = newDate;
      });
    }
  }

  FilledButton _btnChooseContainer(
      BuildContext ctxt, Map<RescueContainer, bool> containers) {
    var visible = containers.entries.where((element) => element.value).toList();
    return FilledButton(
        onPressed: () {
          showDialog(context: ctxt, builder: (ctx) => ModalContainerChooser());
        },
        child: RescueText.normal(
            "Choose container (${visible.length} / ${containers.length})"));
  }

  Future<DateTime?> _dialogBuilder(BuildContext context, [DateTime? initial]) {
    return showDialog<DateTime?>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: initial ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
      },
    );
  }
}
