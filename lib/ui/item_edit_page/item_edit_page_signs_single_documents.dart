import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/models/firebase_document.dart';
import 'package:rescuenet_warehouse/firebase_utils.dart';
import 'package:rescuenet_warehouse/ui/label_with_multiple_entries.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

class ItemEditPageSignsSingleDocuments extends StatelessWidget {
  final String label;
  final List<FirebaseDocument> docs;
  final Function(List<FirebaseDocument>) updatedDocs;

  ItemEditPageSignsSingleDocuments(this.label, this.docs, this.updatedDocs);

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LabelWithMultipleEntries(label, _addNew, _entries(), 536));

  List<Widget> _entries() => docs.map(_docRow).toList();

  Widget _docRow(FirebaseDocument doc) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText.slim(doc.name),
          InkWell(
              onTap: () => _removeDoc(doc),
              child: Center(child: RescueText.headline('-'))),
        ],
      );

  _removeDoc(FirebaseDocument doc) {
    _changePaths(doc.id, null);
  }

  void _addNew([String? prevId]) async {
    var id = prevId ?? uuid.v4();
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    var platformFile = result.files.single;
    var name = platformFile.name;
    var destination = "safety_datasheets/$name";

    try {
      if (kIsWeb) {
        // Web: Use bytes
        var bytes = platformFile.bytes;
        if (bytes == null) {
          // Handle error - show snackbar or dialog
          return;
        }
        await uploadData(destination, bytes, 'application/pdf');
      } else {
        // Native: Use file path
        var path = platformFile.path;
        if (path == null) {
          // Handle error - show snackbar or dialog
          return;
        }
        var file = File(path);
        await uploadFile(destination, file);
      }

      _changePaths(
        id,
        FirebaseDocument(id: id, url: destination, name: name),
      );
    } catch (e) {
      // Handle upload error - show snackbar or dialog
      debugPrint('Failed to upload safety datasheet: $e');
    }
  }

  _changePaths(String id, FirebaseDocument? doc) {
    var newPaths = List<FirebaseDocument>.from(docs);
    newPaths.removeWhere((element) => element.id == id);
    if (doc != null) newPaths.add(doc);
    updatedDocs(newPaths);
  }
}
