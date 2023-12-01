import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/assignment_service.dart';
import 'package:rescuenet_warehouse/container_service.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import '../../models/item.dart';
import '../rescue_dropdown_button.dart';
import '../rescue_text.dart';

class ItemEditPageAmountsAddContainer extends StatefulWidget {
  final Item item;
  final Set<String> knownNames;

  ItemEditPageAmountsAddContainer(this.item, this.knownNames);

  @override
  State createState() => _ItemEditPageAmountsAddContainerState();
}

class _ItemEditPageAmountsAddContainerState
    extends State<ItemEditPageAmountsAddContainer> {
  ValueNotifier<String> valueNotifier = ValueNotifier("");

  @override
  Widget build(BuildContext context) => Consumer<ContainerService>(
      builder: (ctx, service, _) =>
          _body(_options(service.otherContainerOptions(widget.item))));

  Map<String, String> _options(List<RescueContainer> otherOptions) {
    var availableOptions = [...otherOptions];
    availableOptions
        .removeWhere((cont) => widget.knownNames.contains(cont.printName));
    return Map.fromEntries(
        availableOptions.map((e) => MapEntry(e.id, e.printName)));
  }

  @override
  void initState() {
    super.initState();

    valueNotifier.addListener(() {
      setState(() {});
    });
  }

  _body(Map<String, String> otherContainerOptions) {
    if (otherContainerOptions.isEmpty) {
      return RescueText.slim("No new containers available");
    }
    return _containerSelector(otherContainerOptions);
  }

  _containerSelector(Map<String, String> otherContainerOptions) {
    if (otherContainerOptions[valueNotifier.value] == null) {
      valueNotifier.dispose();
      var options = otherContainerOptions.entries.first;
      valueNotifier = _newListener(options.key);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      RescueDropdownButton(otherContainerOptions, valueNotifier),
      IconButton(
          onPressed: () => _addNewContainer(valueNotifier.value),
          icon: const Icon(Icons.add))
    ]);
  }

  _addNewContainer(String containerIdToAdd) =>
      Provider.of<AssignmentService>(context, listen: false)
          .addContainer(containerIdToAdd, widget.item);

  _newListener(String selectedValue) {
    ValueNotifier<String> valueNotifier = ValueNotifier(selectedValue);
    valueNotifier.addListener(() {
      setState(() {});
    });
    return valueNotifier;
  }
}
