import 'package:flutter/material.dart';
import 'diff_fields_table.dart';

/// A card that displays either a new item or an updated item with differences
class RowDiffCard<T> extends StatelessWidget {
  /// The imported object
  final T importedObject;

  /// The existing object to compare with (can be null)
  final T? existingObject;

  /// Display name for the object
  final String displayName;

  /// List of fields to display
  final List<String> fieldsToShow;

  /// List of differences (if comparing with existing)
  final List<String> differences;

  const RowDiffCard({
    Key? key,
    required this.importedObject,
    this.existingObject,
    required this.displayName,
    required this.fieldsToShow,
    this.differences = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return existingObject == null
        ? _buildNewItemCard(context)
        : _buildDiffCard(context);
  }

  /// Builds a card for a newly imported item (no existing match)
  Widget _buildNewItemCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New: $displayName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  DiffFieldsTable<T>(
                    importedObject: importedObject,
                    fieldsToShow: fieldsToShow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a card showing differences between imported and existing items
  Widget _buildDiffCard(BuildContext context) {
    final hasDifferences = differences.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: hasDifferences ? Colors.amber.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: hasDifferences ? Colors.amber : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasDifferences ? Icons.compare_arrows : Icons.check,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDifferences
                        ? 'Update: $displayName'
                        : 'No Changes: $displayName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  if (hasDifferences || fieldsToShow.isNotEmpty)
                    DiffFieldsTable<T>(
                      importedObject: importedObject,
                      existingObject: existingObject,
                      fieldsToShow: fieldsToShow,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
