import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_service.dart';

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

    return SizedBox(
      width: 562,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
              width: 152,
              child: Row(
                children: [
                  RescueText.slim('Expiring dates:'),
                  Expanded(
                      child: TextButton(
                          onPressed: () => _chooseDate(context, null),
                          child: RescueText.headline('+'))),
                ],
              )),
          Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dates.map((e) => _expDateRow(e, context)).toList()),
        ],
      ),
    );
  }

  Container _expDateRow(DateTime date, BuildContext context) {
    return Container(
      width: 400,
      height: 39,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(width: 0.50),
          top: BorderSide(width: 0.50),
          right: BorderSide(width: 0.50),
          bottom: BorderSide(),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText.slim(formatter.format(date)),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () => _removeDate(context, date),
                  child: Center(child: RescueText.headline('-'))),
              const SizedBox(width: 8),
              TextButton(
                  onPressed: () => _chooseDate(context, date),
                  child: RescueText.slim("choose"))
            ],
          ),
        ],
      ),
    );
  }

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
