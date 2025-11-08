import 'package:flutter/material.dart';

/// Shows modal with format-specific Print/Save options for labels
Future<void> showLabelExportOptionsModal({
  required BuildContext context,
  required Future<void> Function() onPrintA6,
  required Future<void> Function() onPrintA4,
  required Future<void> Function() onSaveA6,
  required Future<void> Function() onSaveA4,
}) async {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            // A6 section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'A6 Format (one per page)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print A6'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onPrintA6();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Printed A6 labels')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error printing A6: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save A6'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onSaveA6();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved A6 labels')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving A6: $e')),
                  );
                }
              },
            ),
            const Divider(),
            // A4 section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'A4 Format (2×2 grid - 4 per page)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print A4'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onPrintA4();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Printed A4 labels')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error printing A4: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save A4'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await onSaveA4();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved A4 labels')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving A4: $e')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel),
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
