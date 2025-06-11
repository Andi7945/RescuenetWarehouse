import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

class AssignmentSearchAttribute extends StatelessWidget {
  final String label;
  final String value;

  const AssignmentSearchAttribute({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RescueText.slim(label),
          const SizedBox(height: 4),
          RescueText.normal(value),
        ],
      ),
    );
  }
}
