import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/sign.dart';

class IndicatorSign extends StatelessWidget {
  final Sign sign;

  const IndicatorSign({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/signes/${sign.imagePath}");
  }
}