import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

class ItemEditPageAmounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return Container(
      width: 562,
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RescueText.slim('Amounts: '),
          const SizedBox(height: 10),
          _container('1: Office supplies', "2", true),
          const SizedBox(height: 10),
          _container('2: Power', "1", true),
          const SizedBox(height: 10),
          _container('Remaining', "3", false),
          const SizedBox(height: 10),
          Container(
            width: 239,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _container('Total', "6", true),
        ],
      ),
    );
  }

  Widget _container(String label, String count, bool adjustable) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RescueText.slim(label),
        const SizedBox(width: 10),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (adjustable) RescueText.normal("-"),
              const SizedBox(width: 10),
              RescueText.normal(count),
              const SizedBox(width: 10),
              if (adjustable) RescueText.normal("+"),
            ],
          ),
        ),
      ],
    );
  }
}
