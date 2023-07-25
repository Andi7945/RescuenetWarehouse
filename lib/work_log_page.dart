import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';
import 'package:rescuenet_warehouse/store.dart';

import 'log_entry.dart';
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

  Widget _date(MapEntry<String, List<LogEntryExpanded>> date) => Column(
        children: [
          RescueText.headline(date.key),
          ...date.value.map(_entry).toList(),
        ],
      );

  Widget _entry(LogEntryExpanded entry) {
    return ListTile(
        title: Text(
            "${entry.item.name} -> ${entry.container?.name}: ${entry.count}"));
  }
}
