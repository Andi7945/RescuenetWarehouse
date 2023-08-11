import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_edit_page.dart';
import 'package:rescuenet_warehouse/menu_option.dart';

import 'item_service.dart';
import 'menu.dart';

class ItemEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.itemOverview),
      Expanded(child: _page(id))
    ]));
  }

  _page(String id) => Consumer<ItemService>(
      builder: (ctxt, itemService, _) =>
          ItemEditPage(itemService.itemById(id)));
}
