import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item_edit_page.dart';

import 'menu.dart';

class ItemEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: Column(children: [Menu(), Expanded(child: _page(id))]));
  }

  _page(String id) => ItemEditPage(id);
}
