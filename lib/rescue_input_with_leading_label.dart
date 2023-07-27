import 'package:flutter/material.dart';

import 'rescue_input.dart';
import 'rescue_text.dart';

class RescueInputWithLeadingLabel extends StatelessWidget {
  final String label;
  final String? initial;
  final Function(String) updateFn;

  RescueInputWithLeadingLabel(this.label, this.updateFn, this.initial);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 562,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText.slim(label),
          const SizedBox(width: 10),
          SizedBox(
            width: 400,
            child: RescueInput(initial ?? "", updateFn),
          ),
        ],
      ),
    );
  }
}
