import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rescuenet_warehouse/ui/image_picker_dialog.dart';

import 'package:rescuenet_warehouse/main.dart';

import '../firebase_utils.dart';
import 'rescue_image.dart';
import 'rescue_text.dart';

class RescuePickableImage extends StatelessWidget {
  final Function(String) picked;
  final double? height;
  final double? width;
  final String? path;

  RescuePickableImage(this.path, this.picked, [this.height, this.width]);

  @override
  Widget build(BuildContext context) {
    return RescueImage(
      path,
      height ?? 168,
      width ?? 151,
      _changePictureOverview(context),
    );
  }

  _changePictureOverview(BuildContext context) => Center(
    child: InkWell(
      child: Container(
        width: 144,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xD3D9D9D9),
          border: Border.all(width: 1),
        ),
        child: Center(child: RescueText.slim('Change picture...')),
      ),
      onTap: () => _showPicker(context),
    ),
  );

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Previously uploaded'),
                onTap: () async {
                  await loadFromFirebase(context);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  imgFrom(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  imgFrom(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final ImagePicker _picker = ImagePicker();

  Future imgFrom(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source).catchError((
      onError,
    ) {
      print("Error on image taken by cam: $onError");
    });

    final firebaseId = uuid.v4();
    final destination = 'images/$firebaseId';
    if (pickedFile != null) {
      if (kIsWeb) {
        // Access file contents as bytes. In the browser we can not use the file path
        pickedFile.readAsBytes().then((bytes) async {
          var uploadedPath = await uploadData(
            destination,
            bytes,
            pickedFile.mimeType,
          );
          print("Uploaded file to $uploadedPath, now return thumbnail");
          picked(await loadThumbnailPathFromFirebase(firebaseId));
        });
      } else {
        var uploadedPath = await uploadFile(destination, File(pickedFile.path));
        print("Uploaded file to $uploadedPath, now return thumbnail");
        picked(await loadThumbnailPathFromFirebase(firebaseId));
      }
    }
  }

  Future loadThumbnailPathFromFirebase(String firebaseId) async {
    final ref = firebase_storage.FirebaseStorage.instance;
    var refThumb = ref.ref("images/thumbs/${firebaseId}_100x100");
    return await _tryLoadThumbnail(refThumb, 0);
  }

  Future<String> _tryLoadThumbnail(Reference ref, int errorCount) async {
    return Future.delayed(
      // Delay for thumbnails to be created by firebase
      const Duration(seconds: 1),
      () async => ref.getDownloadURL(),
    ).catchError((_) async {
      if (errorCount < 3) {
        print("Did not find, retry loading thumbnail (retry $errorCount)");
        return await _tryLoadThumbnail(ref, errorCount + 1);
      } else {
        print(
          "Too many errors. Could not load thumbnail (Errors: $errorCount)",
        );
        return Future.error(
          Exception(
            "Too many errors. Could not load thumbnail (Errors: $errorCount)",
          ),
        );
      }
    });
  }

  Future loadFromFirebase(BuildContext context) async {
    String? pickedFile = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: 1000,
          child: SimpleDialog(
            title: RescueText.normal("Load image from firebase"),
            children: [ImagePickerDialog()],
          ),
        );
      },
    );
    if (pickedFile != null) {
      picked(pickedFile);
    }
  }
}
