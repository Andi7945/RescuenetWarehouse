import 'package:flutter/material.dart';

class ContainerOverviewPageHeadline {
  buildContainerHeadline() => TableRow(children: [
        Container(),
        const SizedBox(width: 16),
        _headlineText("Image"),
        const SizedBox(width: 16),
        _headlineText("Name"),
        _headlineText("Currently deployed"),
        _headlineText("Total amount")
      ]);

  _headlineText(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 32,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      );
}
