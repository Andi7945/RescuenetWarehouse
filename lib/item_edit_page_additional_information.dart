import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/item_edit_page_additional_information_exp_dates.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';
import 'package:rescuenet_warehouse/rescue_input.dart';
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
      _entry(
          'Description:',
          _updateItem(context, (s) => Item.from(item: item, description: s)),
          item.description),
      const SizedBox(height: 10),
      ItemEditPageAdditionalInformationExpDates(item),
      const SizedBox(height: 10),
      _operationalStatusEntry(
          context, 'Operational status:', item.operationalStatus.name),
      const SizedBox(height: 10),
      _entry(
          'Manufacturer:',
          _updateItem(context, (s) => Item.from(item: item, manufacturer: s)),
          item.manufacturer),
      const SizedBox(height: 10),
      _entry(
          'Brand:',
          _updateItem(context, (s) => Item.from(item: item, brand: s)),
          item.brand),
      const SizedBox(height: 10),
      _entry(
          'Type:',
          _updateItem(context, (s) => Item.from(item: item, type: s)),
          item.type),
      const SizedBox(height: 10),
      _entry(
          'Supplier:',
          _updateItem(context, (s) => Item.from(item: item, supplier: s)),
          item.supplier),
      const SizedBox(height: 10),
      _entry('SKU:',
          _updateItem(context, (s) => Item.from(item: item, sku: s)), item.sku),
      const SizedBox(height: 10),
      _entry(
          'Website:',
          _updateItem(context, (s) => Item.from(item: item, website: s)),
          item.website),
      const SizedBox(height: 10),
      _entry(
          'Value:',
          _updateItem(context, (s) => Item.from(item: item, value: s)),
          item.value)
    ]);
  }

  Function(String) _updateItem(
          BuildContext context, Item Function(String) updateFn) =>
      (s) => Provider.of<Store>(context, listen: false).updateItem(updateFn(s));

  Widget _entry(String label, Function(String) updateFn, String? initial) =>
      SizedBox(
        width: 562,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RescueText.slim(label),
            const SizedBox(width: 10),
            SizedBox(
              width: 400,
              child: RescueInput.plain(initial ?? "", updateFn),
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
