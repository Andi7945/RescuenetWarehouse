import 'package:flutter/material.dart';

enum SequentialBuild {
  preBuild(color: Colors.orange, displayName: "Pre Build"),
  firstBuild(color: Color.fromRGBO(255, 245, 0, 1), displayName: "First Build"),
  laterBuild(color: Color.fromRGBO(0, 255, 41, 1), displayName: "Later Build"),
  supplies(color: Color.fromRGBO(0, 250, 250, 1), displayName: "Supplies");

  const SequentialBuild({required this.color, required this.displayName});

  final Color color;
  final String displayName;
}
