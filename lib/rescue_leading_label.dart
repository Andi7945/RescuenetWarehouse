import 'package:flutter/material.dart';

import 'rescue_text.dart';

class RescueLeadingLabel extends StatelessWidget {
  final Widget w;
  final double? width;
  final String label;

  RescueLeadingLabel(this.w, this.label, [this.width]);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: width ?? 562),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText.slim(label),
          const SizedBox(width: 10),
          Expanded(child: w),
        ],
      ),
    );
  }
}
