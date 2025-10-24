import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

/// Handles file system operations for PDFs
class FileService {
  /// Saves PDF bytes to local storage using cross-platform file saver.
  ///
  /// On web: Triggers browser download dialog.
  /// On mobile/desktop: Opens native file picker or saves to documents directory.
  ///
  /// Returns the file path where the file was saved (empty string on web).
  ///
  /// Pure function with no side effects beyond file I/O.
  static Future<String> saveToLocalFile(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    final filePath = await FileSaver.instance.saveFile(
      name: _stripExtension(fileName),
      bytes: pdfBytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );

    return filePath ?? '';
  }

  /// Strips file extension from filename.
  ///
  /// file_saver expects name without extension (adds it via ext parameter).
  /// Pure function for easy testing and reusability.
  ///
  /// Examples:
  /// - "packing_list.pdf" → "packing_list"
  /// - "container_labels.pdf" → "container_labels"
  /// - "no_extension" → "no_extension"
  static String _stripExtension(String fileName) {
    if (fileName.endsWith('.pdf')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }

  /// Save multiple PDFs
  static Future<List<String>> saveMultipleToLocalFiles(
    List<(String fileName, Uint8List bytes)> pdfs,
  ) async {
    final paths = <String>[];
    for (final (fileName, bytes) in pdfs) {
      final path = await saveToLocalFile(bytes, fileName);
      paths.add(path);
    }
    return paths;
  }
}
