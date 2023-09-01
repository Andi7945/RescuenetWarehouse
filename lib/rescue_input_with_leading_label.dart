import 'package:flutter/material.dart';

import 'rescue_input.dart';
import 'rescue_leading_label.dart';

class RescueInputWithLeadingLabel extends StatelessWidget {
  final String? initial;
  final Function(String) updateFn;
  final bool? digitsOnly;
  final double? width;
  final String label;

  RescueInputWithLeadingLabel(this.label, this.updateFn, this.initial,
      [this.width, this.digitsOnly]);

  @override
  Widget build(BuildContext context) {
    return RescueLeadingLabel(
      RescueInputText(initial: initial, onChange: updateFn),
      label,
      width,
    );
  }
}
