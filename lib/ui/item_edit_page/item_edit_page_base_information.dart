import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text.dart';
import 'package:rescuenet_warehouse/ui/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../state/current_item_notifier.dart';

class ItemEditPageBaseInformation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var item = ref.watch(currentItemNotifierProvider);
    if (item == null) {
      return CircularProgressIndicator();
    }
    return _body(ref, item);
  }

  _body(WidgetRef ref, Item item) => Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _leftSide(ref, item)),
            Expanded(flex: 2, child: _rightSide(ref, item))
          ],
        ),
      );

  Widget _leftSide(WidgetRef ref, Item item) => RescuePickableImage(
      item.imagePath,
      (path) => _changeItem(ref, item.copyWith(imagePath: path)));

  Widget _rightSide(WidgetRef ref, Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._widgetWithLabel("Name:", _nameInput(ref, item)),
          const SizedBox(height: 8),
          ..._widgetWithLabel("RescueNet ID:",
              RescueText.normal(item.rescueNetId.toStringAsFixed(0)))
        ],
      ),
    );
  }

  RescueInputText _nameInput(WidgetRef ref, Item item) => RescueInputText(
      fontSize: 24,
      initial: item.name,
      onChange: (changed) => _changeItem(ref, item.copyWith(name: changed)));

  List<Widget> _widgetWithLabel(String label, Widget w) {
    return [
      RescueText.slim(label),
      const SizedBox(height: 8),
      SizedBox(height: 40, child: w)
    ];
  }

  _changeItem(WidgetRef ref, Item updated) {
    ref.read(currentItemNotifierProvider.notifier).update(updated);
  }
}
