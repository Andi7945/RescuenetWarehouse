import 'package:flutter/material.dart';

class RescueImage extends StatelessWidget {
  final String? _imagePath;

  RescueImage(this._imagePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 80.89,
      decoration: _imageDecoration(),
    );
  }

  _imageDecoration() {
    if (_imagePath == null) {
      return;
    }
    return BoxDecoration(
      image: DecorationImage(
        // image: NetworkImage(_item.imagePath),
        image: AssetImage("assets/images/$_imagePath"),
        fit: BoxFit.fill,
      ),
    );
  }
}
