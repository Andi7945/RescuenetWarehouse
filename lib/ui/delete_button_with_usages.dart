import 'package:flutter/material.dart';

import 'confirm_dialog.dart';

class DeleteButtonWithUsages extends StatelessWidget {
  final Set<String> usedIn;
  final VoidCallback? onDelete;
  final IconData iconData;

  DeleteButtonWithUsages(
    this.usedIn,
    this.onDelete, {
    this.iconData = Icons.remove,
  });

  @override
  Widget build(BuildContext context) {
    return (usedIn.isEmpty) ? _btnDeleteEnabled(context) : _btnDeleteDisabled();
  }

  _btnDeleteEnabled(BuildContext context) => _btn(_delete(context));

  _delete(context) => () async {
    if (onDelete != null &&
        await confirm(
          context,
          content: Text("Do you really want to delete?"),
          textOK: Text("Delete"),
        )) {
      print('pressedOK - Delete');
      onDelete!();
    }
    return print('pressedCancel - Do not delete');
  };

  _btnDeleteDisabled() => Tooltip(
    showDuration: const Duration(milliseconds: 3000),
    message: "Can not delete. Value is still used in: ${_usedIn()}",
    triggerMode: TooltipTriggerMode.tap,
    child: _btn(null),
  );

  IconButton _btn(VoidCallback? onPressed) =>
      IconButton(icon: Icon(iconData), onPressed: onPressed);

  String _usedIn() {
    var used = usedIn.toList();
    used.sort();
    return used.join(", ");
  }
}
