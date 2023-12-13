import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/services/container_visibility_service.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/ui/work_log_page/work_log_page_body_from_date.dart';
import 'package:rescuenet_warehouse/services/work_log_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../rescue_navigation_drawer.dart';
import 'work_log_page_body_all.dart';

class WorkLogPage extends StatefulWidget {
  const WorkLogPage({super.key});

  @override
  State createState() => _WorkLogPageState();
}

class _WorkLogPageState extends State<WorkLogPage> {
  Future<DateTime?> _getDate() async {
    var prefs = await SharedPreferences.getInstance();

    var millisecondsSinceEpoch = prefs.getInt('work_log_instant_filter');
    return millisecondsSinceEpoch != null
        ? DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch)
        : null;
  }

  _saveDate(DateTime? choosen) async {
    var prefs = await SharedPreferences.getInstance();
    if (choosen == null) {
      prefs.remove('work_log_instant_filter');
    } else {
      prefs.setInt('work_log_instant_filter', choosen.millisecondsSinceEpoch);
    }
  }

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

  Widget _body(WorkLogService workLogService) => FutureBuilder(
      future: _getDate(),
      builder: (ctxt, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        var onlyFromDate = snap.data;
        return onlyFromDate == null
            ? WorkLogPageBodyAll(workLogService.byDateAndContainerName())
            : WorkLogPageBodyFromDate(
                onlyFromDate, workLogService.fromDate(onlyFromDate));
      });

  Widget _allChangesButton() => Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilledButton(
          onPressed: () => setState(() {
                _saveDate(null);
              }),
          child: RescueText.slim("all")));

  Widget _dateChooser() => Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilledButton(
          onPressed: () async {
            await _chooseNewDate();
          },
          child: RescueText.slim("since")));

  Future<void> _chooseNewDate() async {
    var initial =
        (await _getDate()) ?? DateTime.now().subtract(const Duration(days: 7));
    var newDate = await _dialogBuilder(context, initial);
    if (newDate != null) {
      setState(() {
        _saveDate(newDate);
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
