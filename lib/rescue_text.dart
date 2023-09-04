import 'package:flutter/material.dart';

class RescueText extends StatelessWidget {
  final double fontSize;
  final String text;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  const RescueText(this.fontSize, this.text, {this.fontWeight, this.textAlign});

  RescueText.headline(String text)
      : this(32, text, fontWeight: FontWeight.w700);

  RescueText.normal(String text, [FontWeight? weight, TextAlign? textAlign])
      : this(24, text, fontWeight: weight, textAlign: textAlign);

  RescueText.slim(String? text, [FontWeight? weight])
      : this(16, text ?? "", fontWeight: weight);

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontFamily: 'Inter',
          fontWeight: fontWeight,
        ),
      );
}
