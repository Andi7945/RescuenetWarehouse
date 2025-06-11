import 'package:flutter/material.dart';

class ItemDeleteButtons extends StatelessWidget {
  final int selected;
  final Function() triggerDeletion;

  const ItemDeleteButtons({
    super.key,
    required this.selected,
    required this.triggerDeletion,
  });

  @override
  Widget build(BuildContext context) => _buttonsInExportMode();

  Widget _buttonsInExportMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: [
        OutlinedButton(
          onPressed: () {
            triggerDeletion();
          },
          child: Text("Delete ($selected)"),
        ),
      ],
    );
  }
}
