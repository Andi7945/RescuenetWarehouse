import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';
import 'package:rescuenet_warehouse/store.dart';
import 'package:rescuenet_warehouse/work_log_page_entry.dart';

import 'log_entry_expanded.dart';
import 'menu.dart';
import 'menu_option.dart';

class WorkLogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            children: [Menu(MenuOption.workLog), Expanded(child: _body())]));
  }

  _body() =>
      Consumer<Store>(builder: (ctxt, store, _) => _page(store.logEntries));

  _page(Map<String, List<LogEntryExpanded>> log) => ListView(
        shrinkWrap: true,
        children: log.entries
            .map((MapEntry<String, List<LogEntryExpanded>> date) => _date(date))
            .toList(),
      );

  Widget _date(MapEntry<String, List<LogEntryExpanded>> date) => Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 8, bottom: 8),
      child: Container(
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
          ),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: RescueText.headline(date.key)),
            _tables(date.value)
          ])));

  Widget _tables(List<LogEntryExpanded> entries) => Column(
      children:
          entries.groupBy((p0) => p0.container).entries.map(_table).toList());

  Widget _table(MapEntry<RescueContainer?, List<LogEntryExpanded>> entry) =>
      Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 24, left: 8, right: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child:
                    RescueText.headline("Container: ${entry.key?.name ?? ""}")),
            Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [header(), ...entry.value.map(item).toList()])
          ]));
}
