import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/firebase_document.dart';
import 'package:rescuenet_warehouse/firebase_utils.dart';
import 'package:rescuenet_warehouse/main.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';
import 'package:rescuenet_warehouse/sign.dart';

import 'rescue_leading_label.dart';

class ItemEditPageSignsSingleSds extends StatelessWidget {
  final Sign sign;
  final Function(Sign) fnUpdated;

  ItemEditPageSignsSingleSds(this.sign, this.fnUpdated);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RescueLeadingLabel(
          _entries(),
          "SDS",
          546,
        ));
  }

  Widget _entries() => Column(
        children: [...sign.sdsPath?.map(_single).toList() ?? [], _single(null)],
      );

  Widget _single(FirebaseDocument? entry) => Row(children: [
        Expanded(child: RescueText.normal(entry?.name ?? "")),
        TextButton(
            child: RescueText.slim("upload"),
            onPressed: () async {
              var result = await FilePicker.platform.pickFiles();
              var path = result?.files.single.path;
              if (path != null) {
                File file = File(path);
                var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
                var name = path.substring(lastSeparator + 1);
                var url = await uploadFile("safety_datasheets/$name", file);
                fnUpdated(sign.copyWith(
                    sdsPath: [FirebaseDocument(uuid.v4(), url, name)]));
              }
            }),
      ]);
}
