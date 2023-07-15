import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/item_edit_page_additional_information_exp_dates.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

class ItemEditPageAdditionalInformation extends StatelessWidget {
  final Item item;

  ItemEditPageAdditionalInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return Column(children: [
      _entry('Description:', item.description),
      const SizedBox(height: 10),
      ItemEditPageAdditionalInformationExpDates(item),
      const SizedBox(height: 10),
      _entry('Operational status:', item.operationalStatus.name),
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

  Widget _entry(String label, String? value) {
    return SizedBox(
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
  }
}
