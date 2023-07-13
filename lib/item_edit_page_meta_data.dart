import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

class ItemEditPageMetaData extends StatelessWidget {
  final Item item;

  ItemEditPageMetaData(this.item);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _picture(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RescueText.slim('Name:'),
                const SizedBox(height: 10),
                Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: const ShapeDecoration(
                    shape:
                        RoundedRectangleBorder(side: BorderSide(width: 0.50)),
                  ),
                  child: RescueText.slim(item.name ?? ""),
                ),
                const SizedBox(height: 10),
                RescueText.slim('RescueNet ID:'),
                const SizedBox(height: 10),
                Container(
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const ShapeDecoration(
                      shape:
                          RoundedRectangleBorder(side: BorderSide(width: 0.50)),
                    ),
                    child: RescueText.slim(item.rescueNetId ?? "")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _picture() {
    return SizedBox(
      width: 202,
      height: 195,
      child: Stack(
        children: [
          Positioned(
            left: 17,
            top: 44,
            child: RescueImage(item.imagePath, 168, 151),
          ),
          Positioned(
            left: 37,
            top: 86,
            child: Container(
              width: 144,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xD3D9D9D9),
                border: Border.all(width: 1),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 93,
            child: RescueText.slim('Change picture...'),
          ),
        ],
      ),
    );
  }
}
