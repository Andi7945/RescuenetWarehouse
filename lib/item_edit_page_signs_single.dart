import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item_edit_page_signs_single_documents.dart';
import 'package:rescuenet_warehouse/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';
import 'package:rescuenet_warehouse/rescue_text_field.dart';

import 'rescue_input_text.dart';
import 'sign.dart';

class ItemEditPageSignsSingle extends StatelessWidget {
  final Function(Sign?) fnUpdated;
  final Sign sign;

  ItemEditPageSignsSingle(this.sign, this.fnUpdated);

  @override
  Widget build(BuildContext context) => _sign(context);

  Widget _sign(BuildContext context) => Container(
      padding: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        children: [
          _picAndNumber(),
          _field("Instructions", sign.instructions,
              (p0) => sign.copyWith(instructions: p0)),
          _field("Type", sign.dangerType, (p) => sign.copyWith(dangerType: p)),
          _field("Shipping name", sign.properShippingName,
              (p) => sign.copyWith(properShippingName: p)),
          _doubleField("Max weight cargo", sign.maxWeightCargo,
              (p0) => sign.copyWith(maxWeightCargo: p0)),
          _doubleField("Max weight PAX", sign.maxWeightPAX,
              (p0) => sign.copyWith(maxWeightPAX: p0)),
          _field("Remarks", sign.remarks, (p0) => sign.copyWith(remarks: p0)),
          ItemEditPageSignsSingleDocuments("SDS:", sign.sdsPath,
              (d) => fnUpdated(sign.copyWith(sdsPath: d))),
          ItemEditPageSignsSingleDocuments(
              "Other documents",
              sign.otherDocuments,
              (d) => fnUpdated(sign.copyWith(otherDocuments: d)))
        ],
      ));

  Row _picAndNumber() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
          flex: 1,
          child: RescuePickableImage(sign.imagePath ?? "",
              (path) => fnUpdated(sign.copyWith(imagePath: path)))),
      Expanded(flex: 2, child: _unNumber()),
      _removeButton()
    ]);
  }

  Widget _doubleField(
          String label, double initial, Sign Function(double) onChange) =>
      _field(label, initial.toStringAsFixed(2),
          (p0) => onChange(p0 == null ? 0.0 : double.parse(p0)));

  Widget _field(
      String label, String? initial, Sign Function(String?) onChange) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RescueTextField(
            label: label,
            onChange: (p0) => fnUpdated(onChange(p0)),
            initial: initial));
  }

  Widget _unNumber() => Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RescueText.slim('IATA ID / UN Number:'),
        const SizedBox(height: 10),
        SizedBox(
            height: 40,
            width: 240,
            child: RescueInputText(
                initial: sign.unNumber,
                onChange: (changed) =>
                    fnUpdated(sign.copyWith(unNumber: changed)))),
      ]));

  Widget _removeButton() {
    return InkWell(
        onTap: () => fnUpdated(null),
        child: Center(child: RescueText.headline('-')));
  }
}
