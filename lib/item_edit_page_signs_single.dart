import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_input_with_leading_label.dart';
import 'package:rescuenet_warehouse/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'rescue_input.dart';
import 'sign.dart';

class ItemEditPageSignsSingle extends StatelessWidget {
  final Function(Sign) fnUpdated;
  final Sign sign;

  ItemEditPageSignsSingle(this.sign, this.fnUpdated);

  @override
  Widget build(BuildContext context) => _sign(context);

  Widget _sign(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
        ),
        child: Column(
          children: [
            Row(children: [
              RescuePickableImage(sign.imagePath ?? ""),
              _unNumber()
            ]),
            RescueInputWithLeadingLabel(
                "Instructions",
                (p0) => fnUpdated(Sign.from(sign: sign, instructions: p0)),
                sign.instructions),
            RescueInputWithLeadingLabel(
                "Remarks",
                (p0) => fnUpdated(Sign.from(sign: sign, remarks: p0)),
                sign.remarks),
            RescueInputWithLeadingLabel(
                "SDS",
                (p0) => fnUpdated(Sign.from(sign: sign, sdsPath: p0)),
                sign.sdsPath),
            RescueInputWithLeadingLabel(
                "Other documents",
                (p0) => fnUpdated(Sign.from(sign: sign, otherDocuments: [p0])),
                sign.otherDocuments.join()),
          ],
        ));
  }

  Widget _unNumber() => Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RescueText.slim('UN Number:'),
        const SizedBox(height: 10),
        SizedBox(
            height: 40,
            width: 240,
            child: RescueInput(
                sign.unNumber ?? "",
                (changed) =>
                    fnUpdated(Sign.from(sign: sign, unNumber: changed)))),
      ]));
}
