import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/edit_custom_values_page.dart';

import 'menu.dart';

class EditCustomValuesPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var type = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: Column(children: [Menu(), Expanded(child: _page(type))]));
  }

  _page(String type) => EditCustomValuesPage(type);
}
