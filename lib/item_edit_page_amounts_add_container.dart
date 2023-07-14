import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'item.dart';
import 'rescue_container.dart';
import 'rescue_dropdown_button.dart';
import 'rescue_text.dart';
import 'store.dart';

class ItemEditPageAmountsAddContainer extends StatefulWidget {
  final Item item;

  ItemEditPageAmountsAddContainer(this.item);

  @override
  State createState() => _ItemEditPageAmountsAddContainerState();
}

class _ItemEditPageAmountsAddContainerState
    extends State<ItemEditPageAmountsAddContainer> {
  @override
  Widget build(BuildContext context) => Consumer<Store>(
      builder: (ctx, store, _) =>
          _body(store.otherContainerOptions(widget.item)));

  _body(List<RescueContainer> otherContainerOptions) {
    if (otherContainerOptions.isEmpty) {
      return RescueText.slim("No new containers available");
    }
    return _containerSelector(otherContainerOptions);
  }

  _containerSelector(List<RescueContainer> otherContainerOptions) {
    ValueNotifier<String> valueNotifier =
        ValueNotifier(otherContainerOptions[0].name!);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      RescueDropdownButton(
          otherContainerOptions.map((e) => e.name!).toList(), valueNotifier),
      TextButton(
          onPressed: () => _addNewContainer(valueNotifier.value),
          child: RescueText.slim("Add container"))
    ]);
  }

  _addNewContainer(String containerToAdd) =>
      Provider.of<Store>(context, listen: false)
          .addContainer(containerToAdd, widget.item);
}
