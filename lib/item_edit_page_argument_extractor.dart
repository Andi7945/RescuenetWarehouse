import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_edit_page.dart';

import 'menu.dart';
import 'store.dart';

class ItemEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: Column(children: [Menu(), Expanded(child: _page(id))]));
  }

  _page(String id) => Consumer<Store>(
      builder: (ctxt, store, _) => ItemEditPage(store.itemById(id)));
}
