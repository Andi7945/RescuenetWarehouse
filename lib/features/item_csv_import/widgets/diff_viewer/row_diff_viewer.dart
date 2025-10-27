import 'package:flutter/material.dart';
import '../../services/diff_service.dart';
import 'row_diff_card.dart';

/// A widget that displays the differences between an imported object and an existing one.
/// Shows only changed attributes plus essential fields (id and name).
class RowDiffViewer<T> extends StatelessWidget {
  /// The newly imported object
  final T importedObject;

  /// The existing object to compare with (can be null)
  final T? existingObject;

  /// Optional function to extract a display name for the object
  final String Function(T obj)? displayNameExtractor;

  /// Optional function to get the ID of an object for matching
  final String Function(T obj)? idExtractor;

  /// List of field names to always show, regardless of changes
  final List<String> alwaysShowFields;

  /// Optional list of field names to exclude from comparison and display
  final List<String> excludeFields;

  const RowDiffViewer({
    Key? key,
    required this.importedObject,
    this.existingObject,
    this.displayNameExtractor,
    this.idExtractor,
    this.alwaysShowFields = const ['id', 'name'],
    this.excludeFields = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate display name for the object
    final displayName = _getDisplayName();

    // Determine which fields to show and if there are differences
    final fieldsToShow = DiffService.getFieldsToShow<T>(
      importedObj: importedObject,
      existingObj: existingObject,
      alwaysShowFields: alwaysShowFields,
      excludeFields: excludeFields,
    );

    // Get differences if there's an existing object to compare with
    final differences = existingObject != null
        ? DiffService.getDifferences(
            importedObject,
            existingObject!,
            excludeFields: excludeFields,
          )
        : <String>[];

    // Build the diff card
    return RowDiffCard<T>(
      importedObject: importedObject,
      existingObject: existingObject,
      displayName: displayName,
      fieldsToShow: fieldsToShow,
      differences: differences,
    );
  }

  /// Get a display name for the object
  String _getDisplayName() {
    if (displayNameExtractor != null) {
      return displayNameExtractor!(importedObject);
    }

    // Try to extract name and id if they exist
    try {
      final map = DiffService.objectToMap(importedObject);
      if (map.containsKey('id') && map.containsKey('name')) {
        return '${map['name']} (${map['id']})';
      } else if (map.containsKey('name')) {
        return map['name'].toString();
      } else if (map.containsKey('id')) {
        return 'ID: ${map['id']}';
      }
    } catch (e) {
      // Ignore errors in extracting name/id
    }

    return importedObject.toString();
  }
}
