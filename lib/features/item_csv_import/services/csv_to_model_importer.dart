import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class CsvToModelImporter {
  /// Import a CSV file and convert it to a list of model objects
  ///
  /// Type [T] should be a freezed class with a fromJson constructor
  /// Returns a list of model objects of type [T]
  static Future<List<T>> importCsvToModel<T>({
    required T Function(Map<String, dynamic> json) fromJsonFactory,
    String? filePath,
    bool allowPickFile = true,
    bool debug = false,
  }) async {
    String csvData;

    // Get CSV data from file or file picker
    if (filePath != null) {
      csvData = await _readCsvFile(filePath);
    } else if (allowPickFile) {
      csvData = await _pickAndReadCsvFile();
    } else {
      throw Exception(
        'Either filePath must be provided or allowPickFile must be true',
      );
    }

    // Convert CSV to list of model objects
    return _convertCsvToModels<T>(csvData, fromJsonFactory, debug: debug);
  }

  /// Pick a CSV file using FilePicker and read its contents
  static Future<String> _pickAndReadCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) {
      throw Exception('No file selected');
    }

    print("Reading csv file from ${result.files.single.path}");
    if (kIsWeb) {
      final bytes = result.files.first.bytes!;
      return utf8.decode(bytes);
    } else {
      final file = File(result.files.single.path!);
      return await file.readAsString();
    }
  }

  /// Read CSV file from a given path
  static Future<String> _readCsvFile(String filePath) async {
    if (kIsWeb) {
      throw Exception(
        'Direct file path reading is not supported on web platform',
      );
    } else {
      final file = File(filePath);
      return await file.readAsString();
    }
  }

  /// Convert CSV string data to a list of model objects
  static List<T> _convertCsvToModels<T>(
    String csvData,
    T Function(Map<String, dynamic> json) fromJsonFactory, {
    bool debug = false,
  }) {
    // Parse CSV
    List<List<dynamic>> csvTable = const CsvToListConverter(
      shouldParseNumbers: true,
      allowInvalid: false,
    ).convert(csvData);

    if (csvTable.isEmpty) {
      return [];
    }

    // Extract headers from first row
    List<String> headers = csvTable.first
        .map((e) => e.toString().trim())
        .toList();

    if (debug) {
      print('CSV Headers: $headers');
    }

    // Convert each row to a model object
    List<T> models = [];
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];

      // Skip rows that don't have the expected number of columns
      if (row.length != headers.length) {
        if (debug) {
          print(
            'Skipping row $i: column count mismatch (expected ${headers.length}, got ${row.length})',
          );
        }
        continue;
      }

      // Create JSON object from row
      Map<String, dynamic> rowData = {};
      for (int j = 0; j < headers.length; j++) {
        // Handle special values
        dynamic value = row[j];
        String header = headers[j];

        if (value is String) {
          // Convert "null" string to actual null
          if (value.toLowerCase() == "null") {
            value = null;
          }
          // Convert empty string to null for number fields
          else if (value.isEmpty &&
              (header.contains('id') ||
                  header.contains('count') ||
                  header.contains('number') ||
                  header.contains('amount') ||
                  header.contains('total'))) {
            value = null;
          }
          // Convert "true"/"false" strings to booleans
          else if (value.toLowerCase() == "true") {
            value = true;
          } else if (value.toLowerCase() == "false") {
            value = false;
          }
          // Handle JSON strings that need to be parsed
          else if ((value.startsWith('[') && value.endsWith(']')) ||
              (value.startsWith('{') && value.endsWith('}'))) {
            try {
              value = jsonDecode(value);
              if (debug) {
                print('Parsed JSON string for $header: $value');
              }
            } catch (e) {
              // If it fails to parse, keep as string
              if (debug) {
                print('Failed to parse JSON string for $header: $value');
                print('Error: $e');
              }
            }
          }
        }

        rowData[header] = value;
      }

      // Create model object from JSON
      try {
        if (debug) {
          print('Creating model from row data: $rowData');
        }
        models.add(fromJsonFactory(rowData));
      } catch (e) {
        print('Error creating model from row $i: $e');
        if (debug) {
          print('Row data: $rowData');
        }
        // Continue with next row
      }
    }

    return models;
  }
}
