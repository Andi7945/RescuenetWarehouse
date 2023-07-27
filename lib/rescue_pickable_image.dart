import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'rescue_image.dart';
import 'rescue_text.dart';

class RescuePickableImage extends StatelessWidget {
  final Function(String) picked;
  final String path;

  RescuePickableImage(this.path, this.picked);

  @override
  Widget build(BuildContext context) {
    return RescueImage(path, 168, 151, _changePictureOverview(context));
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
      ));

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
                      imgFrom(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
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
        });
  }

  final ImagePicker _picker = ImagePicker();

  Future imgFrom(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source).catchError((onError) {
      print("Error on image taken by cam: $onError");
    });
    if (pickedFile != null) {
      picked(pickedFile.path);
    }
  }
}
