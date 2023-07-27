import 'package:flutter/material.dart';

import 'rescue_image.dart';
import 'rescue_text.dart';

class RescuePickableImage extends StatelessWidget {
  final String path;

  RescuePickableImage(this.path);

  @override
  Widget build(BuildContext context) {
    return RescueImage(path, 168, 151, _changePictureOverview());
  }

  _changePictureOverview() => Center(
        child: Container(
          width: 144,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xD3D9D9D9),
            border: Border.all(width: 1),
          ),
          child: Center(child: RescueText.slim('Change picture...')),
        ),
      );
}
