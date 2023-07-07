import 'package:flutter/material.dart';

class EditCustomValuesPage extends StatelessWidget {
  final String type;

  EditCustomValuesPage(this.type);

  @override
  Widget build(BuildContext context) {
    return Text("Edit custom values for $type");
  }
}
