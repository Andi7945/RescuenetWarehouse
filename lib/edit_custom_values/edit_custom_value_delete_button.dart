import 'package:flutter/material.dart';

import '../rescue_text.dart';

class EditCustomValueDeleteButton extends StatelessWidget {
  final String name;
  final Set<String>? usedIn;
  final VoidCallback? onDelete;

  EditCustomValueDeleteButton(this.name, this.usedIn, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return (usedIn?.isEmpty == true)
        ? _btnDeleteEnabled(context)
        : _btnDeleteDisabled();
  }

  _btnDeleteEnabled(BuildContext context) => TextButton(
      onPressed: onDelete,
      child: const RescueText(24, '-', FontWeight.w700));

  _btnDeleteDisabled() => Tooltip(
      showDuration: const Duration(milliseconds: 3000),
      message: "Can not delete. Value is still used in: ${usedIn?.join(", ")}",
      triggerMode: TooltipTriggerMode.tap,
      child: const TextButton(
          onPressed: null, child: RescueText(24, '-', FontWeight.w700)));
}
