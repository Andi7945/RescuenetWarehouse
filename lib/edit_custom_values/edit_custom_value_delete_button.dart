import 'package:flutter/material.dart';

import '../rescue_text.dart';

class EditCustomValueDeleteButton extends StatelessWidget {
  final Set<String> usedIn;
  final VoidCallback? onDelete;

  EditCustomValueDeleteButton(this.usedIn, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return (usedIn.isEmpty) ? _btnDeleteEnabled(context) : _btnDeleteDisabled();
  }

  _btnDeleteEnabled(BuildContext context) => FilledButton(
      onPressed: onDelete,
      child: const RescueText(24, '-', fontWeight: FontWeight.w700));

  _btnDeleteDisabled() => Tooltip(
      showDuration: const Duration(milliseconds: 3000),
      message: "Can not delete. Value is still used in: ${_usedIn()}",
      triggerMode: TooltipTriggerMode.tap,
      child: const FilledButton(
          onPressed: null,
          child: RescueText(24, '-', fontWeight: FontWeight.w700)));

  String _usedIn() {
    var used = usedIn.toList();
    used.sort();
    return used.join(", ");
  }
}
