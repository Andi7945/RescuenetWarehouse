import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item.dart';
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
      SizedBox(
        width: 562,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            RescueText.slim('Expiring dates:'),
            RescueText.headline('+'),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _expDateRow('Nov 30th, 2022'),
                _expDateRow('Jun 30th, 2022'),
                _expDateRow('Nov 30th, 2023'),
              ],
            ),
          ],
        ),
      ),
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

  Container _expDateRow(String date) {
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
          RescueText.slim(date),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RescueText.headline('-'),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 33,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://via.placeholder.com/32x33"),
                    fit: BoxFit.fill,
                  ),
                  border: Border.all(width: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
