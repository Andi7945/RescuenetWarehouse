import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/services/container_visibility_service.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/ui/work_log_page/work_log_page_body_from_date.dart';
import 'package:rescuenet_warehouse/services/work_log_service.dart';

import 'package:intl/intl.dart';

import '../rescue_navigation_drawer.dart';
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
    return Consumer2<ContainerVisibilityService, WorkLogService>(
        builder: (ctxt, visibilityService, workLogService, _) => Scaffold(
            appBar: AppBar(title: const Text("Work log"), actions: [
              _allChangesButton(),
              _dateChooser(),
              provideContainerFilterAction(visibilityService, ctxt)
            ]),
            drawer: RescueNavigationDrawer(),
            body: _body(workLogService)));
  }

  Widget _body(WorkLogService workLogService) => onlyFromDate == null
      ? WorkLogPageBodyAll(workLogService.byDateAndContainerName())
      : WorkLogPageBodyFromDate(
          onlyFromDate!, workLogService.fromDate(onlyFromDate!));

  Widget _allChangesButton() => FilledButton(
      onPressed: () => setState(() {
            onlyFromDate = null;
          }),
      child: RescueText.slim("all"));

  Widget _dateChooser() => FilledButton(
      onPressed: () async {
        await _chooseNewDate();
      },
      child: RescueText.slim("since"));

  Future<void> _chooseNewDate() async {
    var newDate = await _dialogBuilder(
        context, DateTime.now().subtract(const Duration(days: 7)));
    if (newDate != null) {
      setState(() {
        onlyFromDate = newDate;
      });
    }
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
