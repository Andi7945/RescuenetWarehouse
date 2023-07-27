import 'package:flutter/material.dart';

class RescueImage extends StatelessWidget {
  final String? _imagePath;
  final double? width;
  final double? height;
  final Widget? child;

  RescueImage(this._imagePath, [this.width, this.height, this.child]);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 90,
      height: height ?? 80.89,
      decoration: _imageDecoration(),
      child: child,
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
