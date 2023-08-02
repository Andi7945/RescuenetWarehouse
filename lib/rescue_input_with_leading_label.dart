import 'package:flutter/material.dart';

import 'rescue_input.dart';
import 'rescue_text.dart';

class RescueInputWithLeadingLabel extends StatelessWidget {
  final String label;
  final String? initial;
  final Function(String) updateFn;
  final double? width;
  final bool? digitsOnly;

  RescueInputWithLeadingLabel(this.label, this.updateFn, this.initial,
      [this.width, this.digitsOnly]);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 562,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText.slim(label),
          const SizedBox(width: 10),
          SizedBox(
            width: _width(),
            child: RescueInput(initial: initial, onChange: updateFn),
          ),
        ],
      ),
    );
  }

  double _width() {
    return (width ?? 562) - 162;
  }
}
