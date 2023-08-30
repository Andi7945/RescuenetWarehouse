import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/firebase_document.dart';
import 'package:rescuenet_warehouse/firebase_utils.dart';
import 'package:rescuenet_warehouse/label_with_multiple_entries.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';
import 'package:rescuenet_warehouse/sign.dart';

class ItemEditPageSignsSingleSds extends StatelessWidget {
  final Sign sign;
  final Function(Sign) fnUpdated;

  ItemEditPageSignsSingleSds(this.sign, this.fnUpdated);

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LabelWithMultipleEntries("SDS:", _pickSds, _entries(), 536));

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
    _changeSdsPath(doc.id, null);
  }

  List<Widget> _entries() => sign.sdsPath?.map(_docRow).toList() ?? [];

  void _pickSds([String? prevId]) async {
    var id = prevId ?? uuid.v4();
    var result = await FilePicker.platform.pickFiles();
    var path = result?.files.single.path;
    if (path != null) {
      File file = File(path);
      var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
      var name = path.substring(lastSeparator + 1);
      var url = await uploadFile("safety_datasheets/$name", file);
      _changeSdsPath(id, FirebaseDocument(id, url, name));
    }
  }

  _changeSdsPath(String id, FirebaseDocument? doc) {
    var newPaths = sign.sdsPath;
    newPaths?.removeWhere((element) => element.id == id);
    if (doc != null) newPaths?.add(doc);
    fnUpdated(sign.copyWith(sdsPath: newPaths));
  }
}
