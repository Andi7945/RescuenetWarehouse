import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rescuenet_warehouse/rescue_image.dart';

class ImagePickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ref = firebase_storage.FirebaseStorage.instance;
    var ref2 = ref.ref("images").listAll();
    return SizedBox(
        width: 1000,
        height: 500,
        child: FutureBuilder(
            future: ref2,
            builder: (ctxt, snap) => _grid(snap.data?.items ?? [])));
  }

  _grid(List<Reference> imageRefs) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      childAspectRatio: 2,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      children: imageRefs.map(_single).toList(),
    );
  }

  Widget _single(Reference imageRef) => FutureBuilder(
      future: imageRef.getDownloadURL(),
      builder: (_, snap) => RescueImage(snap.data));
}
