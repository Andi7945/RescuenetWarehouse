import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Handles file system operations for PDFs
class FileService {
  /// Save PDF bytes to local file system
  /// Returns the full file path
  static Future<String> saveToLocalFile(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
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
