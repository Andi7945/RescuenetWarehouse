import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rescuenet_warehouse/models/log_entry_summed.dart';
import 'package:rescuenet_warehouse/state/work_log_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/ui/work_log_page/work_log_page_all_single_date.dart';

class WorkLogPageBodyAll extends ConsumerWidget {
  final DateFormat formatter = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _body(ref.watch(workLogNotifierProvider));

  _body(
    List<MapEntry<DateTime, List<MapEntry<String, List<LogEntrySummed>>>>>
    byDate,
  ) => ListView(children: byDate.map(_createTableForDate).toList());

  Widget _createTableForDate(
    MapEntry<DateTime, List<MapEntry<String, List<LogEntrySummed>>>> date,
  ) => _bordered(
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: RescueText.headline(formatter.format(date.key)),
        ),
        _tablesPerDate(date.value),
      ],
    ),
  );

  Widget _bordered(Widget w) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Container(
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: w,
    ),
  );

  _tablesPerDate(List<MapEntry<String, List<LogEntrySummed>>> entriesPerDate) {
    return Column(
      children: entriesPerDate
          .map((v) => WorkLogPageAllSingleDate(entries: v.value))
          .toList(),
    );
  }
}
