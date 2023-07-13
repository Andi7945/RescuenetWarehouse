import 'package:flutter/material.dart';

class RescueText extends StatelessWidget {
  final double fontSize;
  final String text;
  final FontWeight? fontWeight;

  const RescueText(this.fontSize, this.text, [this.fontWeight]);

  RescueText.headline(String text) : this(32, text, FontWeight.w700);

  RescueText.normal(String text) : this(24, text);

  RescueText.slim(String text) : this(16, text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontFamily: 'Inter',
          fontWeight: fontWeight,
        ),
      );
}
