import 'package:flutter/material.dart';

import 'menu.dart';

class EditCustomValuesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [Menu(), Text("Edit custom values")]));
  }
}
