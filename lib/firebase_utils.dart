import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

Future<String> uploadFile(String destination, File file) async {
  final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
  await ref.putFile(file);
  return await ref.getDownloadURL();
}

Future<String> uploadData(
  String destination,
  Uint8List bytes,
  String? mimeType,
) async {
  final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
  await ref.putData(
    bytes,
    SettableMetadata(
      contentType: mimeType ?? 'image/png', // This tells Firebase it's an image
      customMetadata: {
        'originalName': "Image",
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    ),
  );
  return await ref.getDownloadURL();
}
