import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'item.dart';
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
  ValueNotifier<String> valueNotifier = ValueNotifier("");

  @override
  Widget build(BuildContext context) => Consumer<Store>(
      builder: (ctx, store, _) =>
          _body(store.otherContainerOptions(widget.item)));

  @override
  void initState() {
    super.initState();

    valueNotifier.addListener(() {
      setState(() {});
    });
  }

  _body(List<String> otherContainerOptions) {
    if (otherContainerOptions.isEmpty) {
      return RescueText.slim("No new containers available");
    }
    return _containerSelector(otherContainerOptions);
  }

  _containerSelector(List<String> otherContainerOptions) {
    if (!otherContainerOptions.contains(valueNotifier.value)) {
      valueNotifier.dispose();
      valueNotifier = _newListener(otherContainerOptions[0]);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      RescueDropdownButton(otherContainerOptions, valueNotifier),
      TextButton(
          onPressed: () => _addNewContainer(valueNotifier.value),
          child: RescueText.slim("Add container"))
    ]);
  }

  _addNewContainer(String containerToAdd) =>
      Provider.of<Store>(context, listen: false)
          .addContainer(containerToAdd, widget.item);

  _newListener(String selectedValue) {
    ValueNotifier<String> valueNotifier = ValueNotifier(selectedValue);
    valueNotifier.addListener(() {
      setState(() {});
    });
    return valueNotifier;
  }
}