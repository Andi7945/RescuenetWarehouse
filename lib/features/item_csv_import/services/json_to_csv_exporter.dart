import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';

class JsonToCsvExporter {
  /// Converts JSON string to CSV format
  /// Returns the CSV data as a string
  static String convertJsonToCsv(String jsonString) {
    // Parse JSON data (assuming it's valid)
    final dynamic jsonParsed = json.decode(jsonString);
    List<Map<String, dynamic>> dataList = [];

    // Handle different JSON structures
    if (jsonParsed is List) {
      // JSON is already a list of objects
      dataList = List<Map<String, dynamic>>.from(
        jsonParsed.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            return {'value': item};
          }
        }),
      );
    } else if (jsonParsed is Map<String, dynamic>) {
      // JSON is a single object
      if (jsonParsed.values.any((v) => v is List)) {
        // Check if any value is a list - use the first list found
        for (var entry in jsonParsed.entries) {
          if (entry.value is List) {
            dataList = List<Map<String, dynamic>>.from(
              (entry.value as List).map((item) {
                if (item is Map<String, dynamic>) {
                  return item;
                } else {
                  return {'value': item};
                }
              }),
            );
            break;
          }
        }
      } else {
        // Single object, add it as a single row
        dataList = [jsonParsed];
      }
    }

    // Get all unique keys across all objects
    final Set<String> headers = {};
    for (var item in dataList) {
      headers.addAll(item.keys);
    }

    // Create CSV rows
    List<List<dynamic>> csvData = [];
    csvData.add(headers.toList()); // Header row

    // Data rows
    for (var item in dataList) {
      List<dynamic> row = [];
      for (var header in headers) {
        var value = item[header] ?? '';
        if (value is List) {
          row.add(jsonEncode(value));
        } else {
          row.add(value);
        }
      }
      csvData.add(row);
    }

    // Convert to CSV
    return const ListToCsvConverter().convert(csvData);
  }

  /// Exports CSV data to a file with the given filename
  /// Returns the path where the file was saved on mobile platforms
  static Future<String?> exportCsv(String csvData, String fileName) async {
    List<int> encodedCsv = utf8.encode(csvData);
    Uint8List csvBytesList = Uint8List.fromList(encodedCsv);

    String path = await FileSaver.instance.saveFile(
      name: fileName,
      bytes: csvBytesList,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
    print('Saved to $path}');
    return path;
  }

  /// Convenience method to convert JSON to CSV and export in one step
  /// Returns the file path on mobile platforms, null on web
  static Future<String?> convertAndExportJson(
    String jsonString, {
    String? fileName,
  }) async {
    fileName ??= 'RescueNet Items ${DateTime.now().toIso8601String()}';
    final csvData = convertJsonToCsv(jsonString);
    return await exportCsv(csvData, fileName);
  }
}
