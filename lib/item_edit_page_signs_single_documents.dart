import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/firebase_document.dart';
import 'package:rescuenet_warehouse/firebase_utils.dart';
import 'package:rescuenet_warehouse/label_with_multiple_entries.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

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
    var result = await FilePicker.platform.pickFiles();
    var path = result?.files.single.path;
    if (path != null) {
      File file = File(path);
      var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
      var name = path.substring(lastSeparator + 1);
      await uploadFile("safety_datasheets/$name", file);
      _changePaths(id, FirebaseDocument(id, "safety_datasheets/$name", name));
    }
  }

  _changePaths(String id, FirebaseDocument? doc) {
    var newPaths = docs;
    newPaths.removeWhere((element) => element.id == id);
    if (doc != null) newPaths.add(doc);
    updatedDocs(newPaths);
  }
}
