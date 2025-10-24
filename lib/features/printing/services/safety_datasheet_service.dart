import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/firebase_document.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'print_service.dart';

/// Service for fetching and printing safety datasheet PDFs from Firebase Storage.
///
/// Safety datasheets are pre-existing PDF files stored in Firebase Storage
/// that are associated with dangerous goods items. This service:
/// 1. Extracts all safety datasheet references from selected containers
/// 2. Fetches each PDF from Firebase Storage
/// 3. Shows native print dialog for each PDF
///
/// Note: Unlike packing lists/labels/summary, safety datasheets are NOT generated.
/// They are existing PDF files that we simply fetch and display.
class SafetyDatasheetService {
  /// Print all safety datasheets for items in the selected containers.
  ///
  /// Extracts all unique safety datasheet references from dangerous goods signs,
  /// fetches them from Firebase Storage, and shows print dialog for each.
  ///
  /// Throws [FirebaseException] if any fetch fails.
  static Future<void> printSafetyDatasheets(
    Map<RescueContainer, Map<Item, int>> containers,
  ) async {
    // Extract all safety datasheet references from items
    final safetySheets = containers
        .flatMapValues((item) => item.signs)
        .expand((sign) => sign.sdsPath)
        .toSet() // Remove duplicates
        .toList();

    // If no safety datasheets, nothing to print
    if (safetySheets.isEmpty) return;

    // Fetch and print each safety datasheet
    for (final document in safetySheets) {
      final bytes = await _fetchFromStorage(document);
      await PrintService.showPrintDialog(bytes);
    }
  }

  /// Fetch PDF bytes from Firebase Storage.
  ///
  /// Uses the document's URL path to fetch the file from Firebase Storage.
  /// Throws [FirebaseException] if fetch fails (file not found, permission denied, etc.)
  static Future<Uint8List> _fetchFromStorage(FirebaseDocument document) async {
    final bytes = await FirebaseStorage.instance
        .ref(document.url)
        .getData();

    if (bytes == null) {
      throw Exception('Failed to fetch safety datasheet: ${document.url}');
    }

    return bytes;
  }
}
