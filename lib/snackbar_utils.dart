import 'package:flutter/material.dart';

showSnackbar(BuildContext context, String text) {
  var snackBar = SnackBar(content: Text(text));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
