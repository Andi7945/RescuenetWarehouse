import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/ui/label_with_multiple_entries.dart';

import '../../models/item.dart';
import '../../state/current_item_notifier.dart';
import '../rescue_text.dart';

import 'package:intl/intl.dart';

class ItemEditPageAdditionalInformationExpDates extends ConsumerWidget {
  final Item item;
  final DateFormat formatter = DateFormat('MMM d, yyyy');

  ItemEditPageAdditionalInformationExpDates(this.item);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _body(context, ref);
  }

  _body(BuildContext context, WidgetRef ref) {
    var dates = [...item.expiringDates];
    dates.sort();
    var entries = dates.map((e) => _expDateRow(e, ref, context)).toList();

    return LabelWithMultipleEntries(
      "Expiring dates:",
      () => _chooseDate(ref, context, null),
      entries,
      562,
    );
  }

  Widget _expDateRow(DateTime date, WidgetRef ref, BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      RescueText.slim(formatter.format(date)),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _removeDate(context, ref, date),
            icon: const Icon(Icons.remove),
          ),
          IconButton(
            onPressed: () => _chooseDate(ref, context, date),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    ],
  );

  _removeDate(BuildContext context, WidgetRef ref, DateTime date) {
    var expDates = [...item.expiringDates];
    expDates.remove(date);
    _updateItem(ref, expDates);
  }

  _chooseDate(
    WidgetRef ref,
    BuildContext context,
    DateTime? initialDate,
  ) async {
    var choosen = await _dialogBuilder(context, initialDate);
    if (choosen != null && context.mounted) {
      var expDates = [...item.expiringDates];
      if (initialDate != null) {
        expDates.remove(initialDate);
      }

      _updateItem(ref, [...expDates, choosen]);
    }
  }

  _updateItem(WidgetRef ref, List<DateTime> dates) {
    var updated = item.copyWith(expiringDates: dates);
    ref.read(currentItemNotifierProvider.notifier).update(updated);
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
          lastDate: DateTime(2030),
        );
      },
    );
  }
}
