import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/store_module_destination.dart';

import 'rescue_text.dart';

class EditCustomValueDeleteButton extends StatelessWidget {
  final String name;
  final Set<String>? usedIn;

  EditCustomValueDeleteButton(this.name, this.usedIn);

  @override
  Widget build(BuildContext context) {
    return (usedIn?.isEmpty == true)
        ? _btnDeleteEnabled(context)
        : _btnDeleteDisabled();
  }

  _btnDeleteEnabled(BuildContext context) => TextButton(
      onPressed: () {
        Provider.of<StoreModuleDestination>(context, listen: false).removeDestination(name);
      },
      child: const RescueText(24, '-', FontWeight.w700));

  _btnDeleteDisabled() => Tooltip(
      showDuration: const Duration(milliseconds: 3000),
      message: "Can not delete. Value is still used in: ${usedIn?.join(", ")}",
      triggerMode: TooltipTriggerMode.tap,
      child: const TextButton(
          onPressed: null, child: RescueText(24, '-', FontWeight.w700)));
}
