import 'package:flutter/material.dart';

import 'log_entry_expanded.dart';
import 'rescue_text.dart';
import 'work_log_page_entry.dart';

class WorkLogPageBodyFromDate extends StatelessWidget {
  final ValueChanged<DateTime>? dateChanger;
  final Map<String, List<LogEntryExpanded>> entriesByContainer;

  WorkLogPageBodyFromDate(this.dateChanger, this.entriesByContainer);

  @override
  Widget build(BuildContext context) {
    return Column(
        children:
            entriesByContainer.entries.map(_tablePerDateAndContainer).toList());
  }

  Widget _tablePerDateAndContainer(
          MapEntry<String, List<LogEntryExpanded>> entry) =>
      Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 24, left: 8, right: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RescueText.headline("Container: ${entry.key}")),
            Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [header(), ...entry.value.map(item).toList()])
          ]));
}
