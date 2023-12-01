import 'package:flutter/material.dart';

import 'rescue_text.dart';

class LabelWithMultipleEntries extends StatelessWidget {
  final String label;
  final Function() onAdd;
  final List<Widget> entries;
  final double width;

  LabelWithMultipleEntries(this.label, this.onAdd, this.entries, this.width);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: width),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
              width: 152,
              child: Row(
                children: [
                  RescueText.slim(label),
                  Expanded(
                      child: IconButton(
                          onPressed: onAdd, icon: const Icon(Icons.add))),
                ],
              )),
          Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.map((e) => _withBorder(e)).toList()),
        ],
      ),
    );
  }

  Container _withBorder(Widget w) {
    return Container(
      height: 39,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(width: 0.50),
          top: BorderSide(width: 0.50),
          right: BorderSide(width: 0.50),
          bottom: BorderSide(),
        ),
      ),
      child: w,
    );
  }
}
