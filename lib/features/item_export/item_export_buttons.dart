import 'package:flutter/material.dart';

class ItemExportButtons extends StatelessWidget {
  final int selectedToExport;
  final Function() triggerExport;
  final Function()? triggerExportAll;

  const ItemExportButtons({
    super.key,
    required this.selectedToExport,
    required this.triggerExport,
    required this.triggerExportAll,
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
            triggerExport();
          },
          child: Text("Export ($selectedToExport)"),
        ),
        OutlinedButton(
          onPressed: triggerExportAll != null
              ? () {
                  triggerExportAll!();
                }
              : null,
          child: Text("Export All"),
        ),
      ],
    );
  }
}
