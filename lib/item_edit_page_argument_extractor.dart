import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_edit_page.dart';
import 'package:rescuenet_warehouse/widget/rescue_navigation_drawer.dart';

import 'item_service.dart';

class ItemEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(title: const Text("Item page")),
        drawer: RescueNavigationDrawer(),
        body: _page(id));
  }

  _page(String id) => Consumer<ItemService>(
      builder: (ctxt, itemService, _) =>
          ItemEditPage(itemService.itemById(id)));
}
