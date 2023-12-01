import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text.dart';
import 'package:rescuenet_warehouse/ui/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../services/item_service.dart';

class ItemEditPageBaseInformation extends StatelessWidget {
  final Item item;

  ItemEditPageBaseInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) => Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _leftSide(context)),
            Expanded(flex: 2, child: _rightSide(context))
          ],
        ),
      );

  Widget _leftSide(BuildContext context) => RescuePickableImage(item.imagePath,
      (path) => _changeItem(context, item.copyWith(imagePath: path)));

  Widget _rightSide(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._widgetWithLabel("Name:", _nameInput(context)),
          const SizedBox(height: 8),
          ..._widgetWithLabel("RescueNet ID:",
              RescueText.normal(item.rescueNetId.toStringAsFixed(0)))
        ],
      ),
    );
  }

  RescueInputText _nameInput(BuildContext context) => RescueInputText(
      initial: item.name,
      onChange: (changed) =>
          _changeItem(context, item.copyWith(name: changed)));

  List<Widget> _widgetWithLabel(String label, Widget w) {
    return [
      RescueText.slim(label),
      const SizedBox(height: 8),
      SizedBox(height: 40, child: w)
    ];
  }

  _changeItem(BuildContext context, Item updated) {
    Provider.of<ItemService>(context, listen: false).updateItem(updated);
  }
}
