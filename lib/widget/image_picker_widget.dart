import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ImageUploads extends StatefulWidget {
  ImageUploads(imagePath, { Key? key}) : super(key: key);
  String? imagePath;
  //Function uploadImage; required this.uploadImage,
  File? photo;

  Future<String?> uploadFile({required imageName}) async {
    if (photo == null) return null;
    //final fileName = basename(_photo!.path);
    final destination = 'images/${imageName}';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination);
      // .child('file/');
      await ref.putFile(photo!);
      //get url from uploaded image
      return await ref.getDownloadURL();
    } catch (e) {
      print('error occured');
    }
  }

  @override
  _ImageUploadsState createState() => _ImageUploadsState();
}

class _ImageUploadsState extends State<ImageUploads> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery).catchError((onError) {
      print("Error on image selection: $onError");
    });

    setState(() {
      if (pickedFile != null) {
        widget.photo = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera).catchError((onError) {
      print("Error on image taken by cam: $onError");
    });

    setState(() {
      if (pickedFile != null) {
        widget.photo = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child:
            //CircleAvatar(
            //  radius: 55,
            //  backgroundColor: const Color(0xffFDCF09),
            //  child:
            widget.imagePath != null ?
            Image.network(widget.imagePath!,
              width: 200,
              height: 200,
              fit: BoxFit.fitHeight,
            ) :
            widget.photo != null
                  ? ClipRRect(
                      //borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        widget.photo!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          //borderRadius: BorderRadius.circular(50)
                      ),
                      width: 200,
                      height: 200,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
      //  )
      ],
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
