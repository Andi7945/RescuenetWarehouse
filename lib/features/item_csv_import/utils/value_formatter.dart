/// Utility class for formatting values for display
class ValueFormatter {
  /// Format a value for display, handling null, lists, maps, etc.
  static String formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is List) return '[${value.map(formatValue).join(', ')}]';
    if (value is Map) {
      return '{${value.entries.map((e) => '${e.key}: ${formatValue(e.value)}').join(', ')}}';
    }
    return value.toString();
  }

  /// Format a field name for display
  /// Converts camelCase to Title Case with spaces
  static String formatFieldName(String fieldName) {
    // Handle special case for 'id' field
    if (fieldName.toLowerCase() == 'id') {
      return 'ID';
    }

    // Convert camelCase to space-separated words
    final result = fieldName.replaceAllMapped(
        RegExp(r'([A-Z])'),
            (match) => ' ${match.group(1)}'
    );

    // Capitalize first letter and trim
    if (result.isEmpty) return result;
    return '${result[0].toUpperCase()}${result.substring(1).trim()}';
  }
}
