import 'package:flutter/material.dart';

/// Shows modal with Print / Save / Cancel options
Future<void> showExportOptionsModal({
  required BuildContext context,
  required Future<void> Function() onPrint,
  required Future<void> Function() onSave,
  required String documentName,
}) async {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onPrint();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Printed $documentName')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error printing: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save on disc'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onSave();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved $documentName')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_presentation),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
