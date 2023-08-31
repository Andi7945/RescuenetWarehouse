import 'package:flutter/material.dart';

import 'log_entry_expanded.dart';
import 'rescue_container.dart';
import 'rescue_text.dart';
import 'work_log_page_entry.dart';

import 'package:intl/intl.dart';

class WorkLogPageBodyAll extends StatelessWidget {
  final DateFormat formatter = DateFormat('MMM d, yyyy');
  final List<
          MapEntry<DateTime,
              List<MapEntry<RescueContainer, List<LogEntryExpanded>>>>>
      byDateAndContainerName;

  WorkLogPageBodyAll(this.byDateAndContainerName);

  @override
  Widget build(BuildContext context) => _body();

  _body() => ListView(
        children: byDateAndContainerName.map(_date).toList(),
      );

  Widget _date(
          MapEntry<DateTime,
                  List<MapEntry<RescueContainer, List<LogEntryExpanded>>>>
              date) =>
      _bordered(Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RescueText.headline(formatter.format(date.key))),
        _tablesPerDate(date.value)
      ]));

  Widget _bordered(Widget w) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
          ),
          child: w));

  Widget _tablesPerDate(
      List<MapEntry<RescueContainer, List<LogEntryExpanded>>> entriesPerDate) {
    return Column(
        children: entriesPerDate.map(_tablePerDateAndContainer).toList());
  }

  Widget _tablePerDateAndContainer(
          MapEntry<RescueContainer?, List<LogEntryExpanded>> entry) =>
      Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 24, left: 8, right: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RescueText.headline(
                    "Container: ${entry.key?.printName ?? ""}")),
            Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [header(), ...entry.value.map(item).toList()])
          ]));
}
