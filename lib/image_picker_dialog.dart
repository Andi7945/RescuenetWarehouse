import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rescuenet_warehouse/rescue_image.dart';

class ImagePickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ref = firebase_storage.FirebaseStorage.instance;
    var ref2 = ref.ref("images/thumbs").listAll();
    return SizedBox(
        width: 1000,
        height: 800,
        child: FutureBuilder(
            future: ref2,
            builder: (ctxt, snap) => _grid(context, snap.data?.items ?? [])));
  }

  _grid(BuildContext context, List<Reference> imageRefs) {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      crossAxisCount: 4,
      children: imageRefs.map((r) => _single(context, r)).toList(),
    );
  }

  Widget _single(BuildContext context, Reference imageRef) => FutureBuilder(
      future: imageRef.getDownloadURL(),
      builder: (_, snap) => SizedBox(
          height: 100,
          width: 100,
          child: InkWell(
              onTap: () => Navigator.pop(context, snap.data),
              child: Card(child: RescueImage(snap.data)))));
}
