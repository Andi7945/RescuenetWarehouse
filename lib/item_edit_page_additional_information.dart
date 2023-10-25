import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/item_edit_page_additional_information_exp_dates.dart';
import 'package:rescuenet_warehouse/item_service.dart';
import 'package:rescuenet_warehouse/operational_status.dart';

import 'rescue_text_field.dart';

class ItemEditPageAdditionalInformation extends StatelessWidget {
  final Item item;

  ItemEditPageAdditionalInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    update<T>(Item Function(T) fn) => _updateItem(context, fn);
    return Column(children: [
      RescueTextField(
          label: 'Description',
          initial: item.description,
          onChange: update((s) => item.copyWith(description: s))),
      const SizedBox(height: 10),
      ItemEditPageAdditionalInformationExpDates(item),
      const SizedBox(height: 10),
      _operationalStatusEntry(
          context, 'Operational status:', item.operationalStatus),
      RescueTextField(
          label: 'Manufacturer',
          initial: item.manufacturer,
          onChange: update((s) => item.copyWith(manufacturer: s))),
      RescueTextField(
          label: 'Remarks',
          initial: item.remarks,
          onChange: update((s) => item.copyWith(remarks: s))),
      RescueTextField(
          label: 'Brand',
          initial: item.brand,
          onChange: update((s) => item.copyWith(brand: s))),
      RescueTextField(
          label: 'Type',
          initial: item.type,
          onChange: update((s) => item.copyWith(type: s))),
      RescueTextField(
          label: 'Supplier',
          initial: item.supplier,
          onChange: update((s) => item.copyWith(supplier: s))),
      RescueTextField(
          label: 'SKU',
          initial: item.sku,
          onChange: update((s) => item.copyWith(sku: s))),
      RescueTextField(
          label: 'Website',
          initial: item.website,
          onChange: update((s) => item.copyWith(website: s))),
      RescueTextField(
          label: 'Value in €:',
          onChange: update((s) => item.copyWith(value: int.parse(s))),
          initial: "${item.value}"),
      RescueTextField(
          label: 'Weight:',
          onChange: update((s) => item.copyWith(weight: double.parse(s))),
          initial: "${item.weight}"),
      CheckboxListTile(
          value: item.isColdChain,
          onChanged: update((b) => item.copyWith(isColdChain: b)),
          title: const Text("Cold chain"))
    ]);
  }

  Function(T) _updateItem<T>(BuildContext context, Item Function(T) updateFn) =>
      (s) => Provider.of<ItemService>(context, listen: false)
          .updateItem(updateFn(s));

  Widget _operationalStatusEntry(
      BuildContext context, String label, OperationalStatus value) {
    return DropdownMenu(
        initialSelection: item.operationalStatus.name,
        onSelected: (String? value) {
          var v = value;
          if (v != null) {
            var changedItem = Item.from(
                item: item,
                operationalStatus: OperationalStatus.values
                    .firstWhere((element) => element.name == v));
            Provider.of<ItemService>(context, listen: false)
                .updateItem(changedItem);
          }
        },
        label: const Text(
          "operational status",
          overflow: TextOverflow.ellipsis,
        ),
        dropdownMenuEntries: OperationalStatus.values
            .map((e) => DropdownMenuEntry(value: e.name, label: e.displayName))
            .toList());
  }
}
