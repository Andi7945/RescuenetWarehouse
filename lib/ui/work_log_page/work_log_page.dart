import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/ui/work_log_page/work_log_page_body_from_date.dart';

import '../../state/work_log_date_filter_notifier.dart';
import '../rescue_navigation_drawer.dart';
import 'work_log_page_body_all.dart';

class WorkLogPage extends river.ConsumerStatefulWidget {
  @override
  river.ConsumerState createState() => _WorkLogPageState();
}

class _WorkLogPageState extends river.ConsumerState<WorkLogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Work log"), actions: [
          _allChangesButton(),
          _dateChooser(),
          ContainerChooserAction()
        ]),
        drawer: RescueNavigationDrawer(),
        body: _body());
  }

  Widget _body() {
    var onlyFromDate = ref.watch(workLogDateFilterNotifierProvider);
    return onlyFromDate == null
        ? WorkLogPageBodyAll()
        : WorkLogPageBodyFromDate();
  }

  Widget _allChangesButton() => Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilledButton(
          onPressed: () => ref
              .read(workLogDateFilterNotifierProvider.notifier)
              .saveDate(null),
          child: RescueText.slim("all")));

  Widget _dateChooser() => Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilledButton(
          onPressed: () async {
            await _chooseNewDate();
          },
          child: RescueText.slim("since")));

  Future<void> _chooseNewDate() async {
    var initial = ref.read(workLogDateFilterNotifierProvider) ??
        DateTime.now().subtract(const Duration(days: 7));
    var newDate = await _dialogBuilder(context, initial);
    if (newDate != null) {
      ref.read(workLogDateFilterNotifierProvider.notifier).saveDate(newDate);
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
