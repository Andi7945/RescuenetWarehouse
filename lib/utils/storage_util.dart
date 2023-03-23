import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class StorageUtil{
  //select image from gallery


  static Future<String> uploadImage(File imageFile) async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    final UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Widget getItemImage({required String id}){
    final ref = FirebaseStorage.instance.ref().child("/images/thumbs/${id}_100x100");
    return FutureBuilder(
      future: ref.getDownloadURL(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return Image.network(snapshot.data.toString(), fit: BoxFit.cover,);
        }else{
          return Image.asset("assets/images/placeholder.png", fit: BoxFit.cover,);
        }
      },
    );
  }



  static Future<String> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await FirebaseStorage.instance.ref(fileName).putFile(file);
      String downloadURL = await FirebaseStorage.instance.ref(fileName).getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e);
      return "";
    }
  }
  //download file from firebase storage and save it in local storage
  static Future<String> downloadFile(String fileName) async {
    var path = await getApplicationDocumentsDirectory();
    //store the file in the documents directory
    var file = File('${path.path}/$fileName');
    try {
      await FirebaseStorage.instance.ref(fileName).writeToFile(file);
      return file.path;
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("Firebase Error: $e");
      return "";
    }
  }
}