import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future<String> uploadFile(String destination, File file) async {
  final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
  await ref.putFile(file);
  return await ref.getDownloadURL();
}
