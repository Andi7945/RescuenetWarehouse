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
  /// Fetch all safety datasheet PDFs as bytes with filenames.
  ///
  /// Extracts all unique safety datasheet references from dangerous goods signs,
  /// fetches them from Firebase Storage, and returns them with suggested filenames.
  ///
  /// Returns a list of tuples containing PDF bytes and suggested filenames.
  /// Returns empty list if no safety datasheets are found.
  ///
  /// Throws [FirebaseException] if any fetch fails.
  static Future<List<(Uint8List bytes, String fileName)>>
  fetchSafetyDatasheetBytes(
    Map<RescueContainer, Map<Item, int>> containers,
  ) async {
    // Extract all safety datasheet references from items
    final safetySheets = containers
        .flatMapValues((item) => item.signs)
        .expand((sign) => sign.sdsPath)
        .toSet() // Remove duplicates
        .toList();

    // If no safety datasheets, return empty list
    if (safetySheets.isEmpty) return [];

    // Fetch each safety datasheet with filename
    final results = <(Uint8List bytes, String fileName)>[];
    for (final document in safetySheets) {
      final bytes = await _fetchFromStorage(document);
      final fileName = _getFileName(document);
      results.add((bytes, fileName));
    }

    return results;
  }

  /// Print all safety datasheets for items in the selected containers.
  ///
  /// Extracts all unique safety datasheet references from dangerous goods signs,
  /// fetches them from Firebase Storage, and shows print dialog for each.
  ///
  /// Throws [FirebaseException] if any fetch fails.
  ///
  /// @deprecated Consider using [fetchSafetyDatasheetBytes] with a modal dialog
  /// for better UX consistency with other export actions.
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

  /// Extract filename from Firebase document.
  ///
  /// Uses document.name if available, otherwise derives from document.url.
  /// Ensures .pdf extension is present.
  static String _getFileName(FirebaseDocument document) {
    String fileName;

    if (document.name.isNotEmpty) {
      fileName = document.name;
    } else {
      // Extract filename from URL path
      final urlPath = document.url;
      final segments = urlPath.split('/');
      fileName = segments.isNotEmpty ? segments.last : 'safety_datasheet';
    }

    // Ensure .pdf extension
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      fileName = '$fileName.pdf';
    }

    return fileName;
  }

  /// Fetch PDF bytes from Firebase Storage.
  ///
  /// Uses the document's URL path to fetch the file from Firebase Storage.
  /// Throws [FirebaseException] with descriptive message if fetch fails.
  ///
  /// Common failures:
  /// - File not found (404)
  /// - Permission denied (403) - check Firebase Storage security rules
  /// - CORS configuration missing (web only) - check Firebase Storage CORS settings
  /// - Network errors
  static Future<Uint8List> _fetchFromStorage(FirebaseDocument document) async {
    try {
      final bytes = await FirebaseStorage.instance.ref(document.url).getData();

      if (bytes == null) {
        throw FirebaseException(
          plugin: 'firebase_storage',
          code: 'download-failed',
          message:
              'Failed to download safety datasheet from storage path: ${document.url}',
        );
      }

      return bytes;
    } on FirebaseException {
      // Firebase exceptions already have good error messages, let them through
      rethrow;
    } catch (e, stackTrace) {
      // Catch any other errors (like ClientException from http package)
      // and wrap them in a FirebaseException with context
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'download-error',
        message:
            'Error downloading safety datasheet from "${document.url}": ${_formatErrorMessage(e)}',
        stackTrace: stackTrace,
      );
    }
  }

  /// Format error message for better debugging.
  ///
  /// Extracts useful information from various error types.
  static String _formatErrorMessage(Object error) {
    final errorStr = error.toString();

    // Common error patterns and their likely causes
    if (errorStr.contains('CORS') || errorStr.contains('Cross-Origin')) {
      return 'CORS error - Firebase Storage CORS configuration may be missing. '
          'Configure CORS rules using: gsutil cors set cors.json gs://[bucket-name]';
    }

    if (errorStr.contains('403') || errorStr.contains('permission')) {
      return 'Permission denied - check Firebase Storage security rules and user authentication';
    }

    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'File not found - the safety datasheet may have been deleted or moved';
    }

    if (errorStr.contains('NetworkError') ||
        errorStr.contains('Failed to fetch')) {
      return 'Network error - check internet connection and Firebase Storage availability';
    }

    // Return original error for unknown cases
    return errorStr;
  }
}
