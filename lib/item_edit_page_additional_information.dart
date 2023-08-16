import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/item_edit_page_additional_information_exp_dates.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:rescuenet_warehouse/rescue_dropdown_button.dart';
import 'package:rescuenet_warehouse/rescue_input_with_leading_label.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'rescue_leading_label.dart';

class ItemEditPageAdditionalInformation extends StatelessWidget {
  final Item item;

  ItemEditPageAdditionalInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    return Column(children: [
      RescueInputWithLeadingLabel(
          'Description:',
          _updateItem(context, (s) => Item.from(item: item, description: s)),
          item.description),
      const SizedBox(height: 10),
      ItemEditPageAdditionalInformationExpDates(item),
      const SizedBox(height: 10),
      _operationalStatusEntry(
          context, 'Operational status:', item.operationalStatus),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel(
          'Manufacturer:',
          _updateItem(context, (s) => Item.from(item: item, manufacturer: s)),
          item.manufacturer),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel(
          'Brand:',
          _updateItem(context, (s) => Item.from(item: item, brand: s)),
          item.brand),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel(
          'Type:',
          _updateItem(context, (s) => Item.from(item: item, type: s)),
          item.type),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel(
          'Supplier:',
          _updateItem(context, (s) => Item.from(item: item, supplier: s)),
          item.supplier),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel('SKU:',
          _updateItem(context, (s) => Item.from(item: item, sku: s)), item.sku),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel(
          'Website:',
          _updateItem(context, (s) => Item.from(item: item, website: s)),
          item.website),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel(
          'Value:',
          _updateItem(
              context, (s) => Item.from(item: item, value: int.parse(s))),
          "${item.value}",
          null,
          true),
      const SizedBox(height: 10),
      RescueInputWithLeadingLabel(
          'Weight:',
          _updateItem(
              context, (s) => Item.from(item: item, weight: double.parse(s))),
          "${item.weight}",
          null,
          true),
      const SizedBox(height: 10),
      RescueLeadingLabel(
          Checkbox(
              value: item.isColdChain,
              onChanged: _updateItem(
                  context, (s) => Item.from(item: item, isColdChain: s))),
          "Cold chain:")
    ]);
  }

  Function(T) _updateItem<T>(BuildContext context, Item Function(T) updateFn) =>
      (s) => Provider.of<ItemService>(context, listen: false)
          .updateItem(updateFn(s));

  Widget _operationalStatusEntry(
      BuildContext context, String label, OperationalStatus value) {
    var notifier = ValueNotifier(value);
    notifier.addListener(() {
      var changedItem = Item.from(
          item: item,
          operationalStatus: OperationalStatus.values
              .firstWhere((element) => element == notifier.value));
      Provider.of<ItemService>(context, listen: false).updateItem(changedItem);
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
              Map.fromEntries(OperationalStatus.values
                  .map((e) => MapEntry(e, e.displayName))),
              notifier),
        ],
      ),
    );
  }
}
