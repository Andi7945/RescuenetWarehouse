/// Service class for managing diff operations between objects
class DiffService {
  /// Gets the list of field names that have different values
  static List<String> getDifferences<T>(
    T imported,
    T existing, {
    List<String> excludeFields = const [],
  }) {
    final importedMap = objectToMap(imported);
    final existingMap = objectToMap(existing);

    return importedMap.keys
        .where((field) => !excludeFields.contains(field))
        .where(
          (field) => !areValuesEqual(importedMap[field], existingMap[field]),
        )
        .toList();
  }

  /// Determines which fields should be shown in the diff display
  static List<String> getFieldsToShow<T>({
    required T importedObj,
    T? existingObj,
    required List<String> alwaysShowFields,
    required List<String> excludeFields,
  }) {
    final importedMap = objectToMap(importedObj);
    List<String> fieldsToShow = [];

    // For new items, show all fields
    if (existingObj == null) {
      fieldsToShow = importedMap.keys
          .where((field) => !excludeFields.contains(field))
          .toList();
    } else {
      // Add always-show fields first
      fieldsToShow.addAll(
        alwaysShowFields
            .where((field) => importedMap.containsKey(field))
            .where((field) => !excludeFields.contains(field)),
      );

      // Add changed fields
      final differences = getDifferences(
        importedObj,
        existingObj,
        excludeFields: excludeFields,
      );
      for (String field in differences) {
        if (!fieldsToShow.contains(field)) {
          fieldsToShow.add(field);
        }
      }
    }

    return fieldsToShow;
  }

  /// Convert an object to a Map
  /// Uses toJson method if available (for freezed objects)
  static Map<String, dynamic> objectToMap<T>(T obj) {
    if (obj is Map<String, dynamic>) {
      return obj;
    }

    try {
      // Try to use toJson if available (for freezed objects)
      final dynamic result = (obj as dynamic).toJson();
      if (result is Map<String, dynamic>) {
        return result;
      }
    } catch (e) {
      // toJson not available, continue with fallback
    }

    // Fallback: manually extract properties using reflection
    // This is a simplified example and might need to be adapted
    return {'toString': obj.toString()};
  }

  /// Check if two values are equal, handling special cases for lists and maps
  static bool areValuesEqual(dynamic value1, dynamic value2) {
    if (identical(value1, value2)) return true;
    if (value1 == null && value2 == null) return true;
    if (value1 == null || value2 == null) return false;

    // Handle List comparison
    if (value1 is List && value2 is List) {
      if (value1.length != value2.length) return false;
      for (int i = 0; i < value1.length; i++) {
        if (!areValuesEqual(value1[i], value2[i])) return false;
      }
      return true;
    }

    // Handle Map comparison
    if (value1 is Map && value2 is Map) {
      if (value1.length != value2.length) return false;
      for (final key in value1.keys) {
        if (!value2.containsKey(key) ||
            !areValuesEqual(value1[key], value2[key])) {
          return false;
        }
      }
      return true;
    }

    // Simple equality for other types
    return value1 == value2;
  }
}
