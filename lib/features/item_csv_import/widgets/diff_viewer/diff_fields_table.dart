import 'package:flutter/material.dart';
import '../../services/diff_service.dart';
import '../../utils/value_formatter.dart';

/// A table widget that displays fields and their values, highlighting differences
class DiffFieldsTable<T> extends StatelessWidget {
  /// The imported object
  final T importedObject;

  /// The existing object to compare with (can be null)
  final T? existingObject;

  /// List of field names to display
  final List<String> fieldsToShow;

  const DiffFieldsTable({
    Key? key,
    required this.importedObject,
    this.existingObject,
    required this.fieldsToShow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fieldsToShow.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No differences or essential fields to display'),
      );
    }

    final importedMap = DiffService.objectToMap(importedObject);
    final existingMap = existingObject != null
        ? DiffService.objectToMap(existingObject!)
        : null;

    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Text(
                'Field',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Text(
                'Value',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Field rows
        ...fieldsToShow.map((field) {
          final importedValue = importedMap[field];
          final existingValue = existingMap?[field];
          final isDifferent =
              existingObject != null &&
              !DiffService.areValuesEqual(importedValue, existingValue);

          return TableRow(
            decoration: isDifferent
                ? BoxDecoration(color: Colors.amber.shade100)
                : null,
            children: [
              // Field name
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                child: Text(
                  ValueFormatter.formatFieldName(field),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Field value(s)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                child: isDifferent
                    ? _buildDiffValues(importedValue, existingValue)
                    : Text(ValueFormatter.formatValue(importedValue)),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Build a widget showing both old and new values for changed fields
  Widget _buildDiffValues(dynamic newValue, dynamic oldValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                ValueFormatter.formatValue(newValue),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                ValueFormatter.formatValue(oldValue),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
