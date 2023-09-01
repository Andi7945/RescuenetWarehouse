import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_input.dart';
import 'package:rescuenet_warehouse/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'item_service.dart';

class ItemEditPageBaseInformation extends StatelessWidget {
  final Item item;

  ItemEditPageBaseInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_leftSide(context), _rightSide(context)],
        ),
      );

  SizedBox _leftSide(BuildContext context) => SizedBox(
      width: 202,
      height: 195,
      child: RescuePickableImage(
          item.imagePath,
          (path) =>
              _changeItem(context, Item.from(item: item, imagePath: path))));

  Widget _rightSide(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._widgetWithLabel("Name:", _nameInput(context)),
          const SizedBox(height: 10),
          ..._widgetWithLabel("RescueNet ID:",
              RescueText.normal(item.rescueNetId.toStringAsFixed(0)))
        ],
      ),
    );
  }

  RescueInputText _nameInput(BuildContext context) => RescueInputText(
      initial: item.name,
      onChange: (changed) =>
          _changeItem(context, Item.from(item: item, name: changed)));

  List<Widget> _widgetWithLabel(String label, Widget w) {
    return [
      RescueText.slim(label),
      const SizedBox(height: 10),
      SizedBox(height: 40, width: 240, child: w)
    ];
  }

  _changeItem(BuildContext context, Item updated) {
    Provider.of<ItemService>(context, listen: false).updateItem(updated);
  }
}
