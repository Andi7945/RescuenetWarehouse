import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/label_with_multiple_entries.dart';

import 'item.dart';
import 'rescue_text.dart';

import 'package:intl/intl.dart';

class ItemEditPageAdditionalInformationExpDates extends StatelessWidget {
  final Item item;
  final DateFormat formatter = DateFormat('MMM d, yyyy');

  ItemEditPageAdditionalInformationExpDates(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    var dates = [...item.expiringDates];
    dates.sort();
    var entries = dates.map((e) => _expDateRow(e, context)).toList();

    return LabelWithMultipleEntries(
        "Expiring dates:", () => _chooseDate(context, null), entries, 562);
  }

  Widget _expDateRow(DateTime date, BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText.slim(formatter.format(date)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () => _removeDate(context, date),
                  child: Center(child: RescueText.headline('-'))),
              const SizedBox(width: 8),
              FilledButton(
                  onPressed: () => _chooseDate(context, date),
                  child: RescueText.slim("choose"))
            ],
          ),
        ],
      );

  _removeDate(BuildContext context, DateTime date) {
    var expDates = [...item.expiringDates];
    expDates.remove(date);
    _updateItem(context, expDates);
  }

  _chooseDate(BuildContext context, DateTime? initialDate) async {
    var choosen = await _dialogBuilder(context, initialDate);
    if (choosen != null && context.mounted) {
      var expDates = [...item.expiringDates];
      if (initialDate != null) {
        expDates.remove(initialDate);
      }

      _updateItem(context, [...expDates, choosen]);
    }
  }

  _updateItem(BuildContext context, List<DateTime> dates) {
    var updated = Item.from(item: item, expiringDates: dates);
    Provider.of<ItemService>(context, listen: false).updateItem(updated);
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
