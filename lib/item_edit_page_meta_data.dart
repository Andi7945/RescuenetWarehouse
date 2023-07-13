import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_image.dart';
import 'package:rescuenet_warehouse/rescue_input.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'store.dart';

class ItemEditPageMetaData extends StatelessWidget {
  final Item item;

  ItemEditPageMetaData(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    var nameController = TextEditingController(text: item.name);
    var rescueNetIdController = TextEditingController(text: item.rescueNetId);
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
                SizedBox(
                    height: 40,
                    width: 240,
                    child: RescueInput(
                        nameController,
                        (changed) => _changeItem(context,
                            Item.from(item: item, name: nameController.text)))),
                const SizedBox(height: 10),
                RescueText.slim('RescueNet ID:'),
                const SizedBox(height: 10),
                SizedBox(
                    height: 40,
                    width: 240,
                    child: RescueInput(
                        rescueNetIdController,
                        (changed) => _changeItem(
                            context,
                            Item.from(
                                item: item,
                                rescueNetId: rescueNetIdController.text)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _changeItem(BuildContext context, Item updated) {
    Provider.of<Store>(context, listen: false).updateItem(updated);
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
