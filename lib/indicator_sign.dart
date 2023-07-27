import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/sign.dart';

class IndicatorSign extends StatelessWidget {
  final Sign sign;

  const IndicatorSign({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    if (sign.imagePath != null && sign.imagePath != "") {
      return Image.asset("assets/signes/${sign.imagePath}");
    }
    return Container();
  }
}
