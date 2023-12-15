import 'package:flutter/material.dart';

class DeleteButtonWithUsages extends StatelessWidget {
  final Set<String> usedIn;
  final VoidCallback? onDelete;

  DeleteButtonWithUsages(this.usedIn, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return (usedIn.isEmpty) ? _btnDeleteEnabled(context) : _btnDeleteDisabled();
  }

  _btnDeleteEnabled(BuildContext context) =>
      IconButton(icon: const Icon(Icons.remove), onPressed: onDelete);

  _btnDeleteDisabled() => Tooltip(
      showDuration: const Duration(milliseconds: 3000),
      message: "Can not delete. Value is still used in: ${_usedIn()}",
      triggerMode: TooltipTriggerMode.tap,
      child: const IconButton(onPressed: null, icon: Icon(Icons.remove)));

  String _usedIn() {
    var used = usedIn.toList();
    used.sort();
    return used.join(", ");
  }
}
