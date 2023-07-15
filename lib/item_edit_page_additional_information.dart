import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/item_edit_page_additional_information_exp_dates.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'store.dart';

class ItemEditPageAdditionalInformation extends StatelessWidget {
  final Item item;

  ItemEditPageAdditionalInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    return Column(children: [
      _entry('Description:', item.description),
      const SizedBox(height: 10),
      ItemEditPageAdditionalInformationExpDates(item),
      const SizedBox(height: 10),
      _operationalStatusEntry(
          context, 'Operational status:', item.operationalStatus.name),
      const SizedBox(height: 10),
      _entry('Manufacturer:', item.manufacturer),
      const SizedBox(height: 10),
      _entry('Brand:', item.brand),
      const SizedBox(height: 10),
      _entry('Type:', item.type),
      const SizedBox(height: 10),
      _entry('Supplier:', item.supplier),
      const SizedBox(height: 10),
      _entry('SKU:', item.sku),
      const SizedBox(height: 10),
      _entry('Website:', item.website),
      const SizedBox(height: 10),
      _entry('Value:', item.value),
    ]);
  }

  Widget _entry(String label, String? value) => SizedBox(
        width: 562,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RescueText.slim(label),
            const SizedBox(width: 10),
            Container(
              width: 400,
              padding: const EdgeInsets.all(10),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
              ),
              child: RescueText.slim(value ?? ""),
            ),
          ],
        ),
      );

  Widget _operationalStatusEntry(
      BuildContext context, String label, String value) {
    var notifier = ValueNotifier(value);
    notifier.addListener(() {
      var changedItem = Item.from(
          item: item,
          operationalStatus: OperationalStatus.values
              .firstWhere((element) => element.name == notifier.value));
      Provider.of<Store>(context, listen: false).updateItem(changedItem);
    });
    return SizedBox(
      width: 562,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText.slim(label),
          const SizedBox(width: 10),
          RescueDropdownButton(
              OperationalStatus.values.map((e) => e.name).toList(), notifier),
        ],
      ),
    );
  }
}
