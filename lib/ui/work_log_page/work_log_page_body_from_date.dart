import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../models/log_entry_expanded.dart';
import 'work_log_page_entry.dart';

import 'package:intl/intl.dart';

class WorkLogPageBodyFromDate extends StatelessWidget {
  final DateTime since;
  final Map<RescueContainer, List<LogEntryExpanded>> entriesByContainer;
  final DateFormat formatter = DateFormat('MMM d, yyyy');

  WorkLogPageBodyFromDate(this.since, this.entriesByContainer);

  @override
  Widget build(BuildContext context) {
    return _bordered(Column(children: [
      Padding(
          padding: const EdgeInsets.only(top: 8),
          child: RescueText.headline(
              "All changes since ${formatter.format(since)}")),
      ...entriesByContainer.entries.map(_tablePerDateAndContainer).toList()
    ]));
  }

  Widget _bordered(Widget w) => Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Container(
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
          ),
          child: w));

  Widget _tablePerDateAndContainer(
          MapEntry<RescueContainer, List<LogEntryExpanded>> entry) =>
      Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 24, left: 8, right: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child:
                    RescueText.headline("Container: ${entry.key.printName}")),
            Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [header(), ...entry.value.map(item).toList()])
          ]));
}
