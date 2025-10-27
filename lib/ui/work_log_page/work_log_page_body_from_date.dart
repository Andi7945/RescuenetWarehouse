import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/work_log_date_filter_notifier.dart';
import 'package:rescuenet_warehouse/state/work_log_since_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/ui/work_log_page/work_log_page_all_single_date.dart';
import 'package:intl/intl.dart';

class WorkLogPageBodyFromDate extends ConsumerWidget {
  final DateFormat formatter = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var date = ref.watch(workLogDateFilterNotifierProvider);
    var formattedDate = date != null ? "since ${formatter.format(date)}" : "";
    var logs = ref.watch(workLogSinceNotifierProvider);

    return _bordered(
      ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RescueText.headline("All changes $formattedDate"),
          ),
          ...logs.entries
              .map((e) => WorkLogPageAllSingleDate(entries: e.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _bordered(Widget w) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 8),
    child: Container(
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: w,
    ),
  );
}
