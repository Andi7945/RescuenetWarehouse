import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/operational_status.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_additional_information_exp_dates.dart';

import '../rescue_input_text.dart';

class ItemEditPageAdditionalInformation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _body(ref);
  }

  _body(WidgetRef ref) {
    update<T>(Item Function(T) fn) => _updateItem(ref, fn);
    var item = ref.watch(currentItemNotifierProvider);
    if (item == null) {
      return CircularProgressIndicator();
    }
    return Column(children: [
      RescueInputText(
          label: 'Description',
          initial: item.description,
          onChange: update((s) => item.copyWith(description: s))),
      const SizedBox(height: 10),
      ItemEditPageAdditionalInformationExpDates(item),
      const SizedBox(height: 10),
      _operationalStatusEntry(ref, item),
      RescueInputText(
          label: 'Manufacturer',
          initial: item.manufacturer,
          onChange: update((s) => item.copyWith(manufacturer: s))),
      RescueInputText(
          label: 'Remarks',
          initial: item.remarks,
          onChange: update((s) => item.copyWith(remarks: s))),
      RescueInputText(
          label: 'Brand',
          initial: item.brand,
          onChange: update((s) => item.copyWith(brand: s))),
      RescueInputText(
          label: 'Type',
          initial: item.type,
          onChange: update((s) => item.copyWith(type: s))),
      RescueInputText(
          label: 'Supplier',
          initial: item.supplier,
          onChange: update((s) => item.copyWith(supplier: s))),
      RescueInputText(
          label: 'SKU',
          initial: item.sku,
          onChange: update((s) => item.copyWith(sku: s))),
      RescueInputText(
          label: 'Website',
          initial: item.website,
          onChange: update((s) => item.copyWith(website: s))),
      RescueInputText(
          label: 'Value in €:',
          onChange: update((s) => item.copyWith(value: int.parse(s))),
          initial: "${item.value}"),
      RescueInputText(
          label: 'Weight in kg:',
          onChange: update((s) => item.copyWith(weight: double.parse(s))),
          initial: "${item.weight}"),
      Container(
          alignment: Alignment.centerLeft,
          width: double.infinity,
          child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: CheckboxListTile(
                  value: item.isColdChain,
                  onChanged:
                      update((b) => item.copyWith(isColdChain: b ?? false)),
                  title: const Text("Cold chain"))))
    ]);
  }

  Function(T) _updateItem<T>(WidgetRef ref, Item Function(T) updateFn) =>
      (s) => ref.read(currentItemNotifierProvider.notifier).update(updateFn(s));

  Widget _operationalStatusEntry(WidgetRef ref, Item item) {
    return DropdownMenu(
        initialSelection: item.operationalStatus.name,
        onSelected: (String? value) {
          var v = value;
          if (v != null) {
            var changedItem = item.copyWith(
                operationalStatus: OperationalStatus.values
                    .firstWhere((element) => element.name == v));
            ref.read(currentItemNotifierProvider.notifier).update(changedItem);
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
