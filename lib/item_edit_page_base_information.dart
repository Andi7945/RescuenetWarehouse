import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_input.dart';
import 'package:rescuenet_warehouse/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'store.dart';

class ItemEditPageBaseInformation extends StatelessWidget {
  final Item item;

  ItemEditPageBaseInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 202,
              height: 195,
              child: RescuePickableImage(
                  item.imagePath,
                  (path) => _changeItem(
                      context, Item.from(item: item, imagePath: path)))),
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
                        initial: item.name,
                        onChange: (changed) => _changeItem(
                            context, Item.from(item: item, name: changed)))),
                const SizedBox(height: 10),
                RescueText.slim('RescueNet ID:'),
                const SizedBox(height: 10),
                SizedBox(
                    height: 40,
                    width: 240,
                    child: RescueInput(
                        initial: item.rescueNetId,
                        onChange: (changed) => _changeItem(context,
                            Item.from(item: item, rescueNetId: changed)))),
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
}
