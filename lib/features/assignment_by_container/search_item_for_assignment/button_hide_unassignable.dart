import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

class ButtonHideUnassignable extends river.ConsumerWidget {
  final bool hide;
  final Function(bool) change;

  const ButtonHideUnassignable(this.hide, this.change, {super.key});

  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    return TextButton(
      onPressed: () => change(!hide),
      child: RescueText.slim(_label(ref)),
    );
  }

  _label(ref) {
    if (hide) {
      return "Show not available";
    }
    return "Hide not available";
  }
}
