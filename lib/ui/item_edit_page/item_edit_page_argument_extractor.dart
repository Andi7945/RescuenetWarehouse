import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';

import '../../services/item_service.dart';

class ItemEditPageArgumentExtractor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemService>(builder: (ctxt, itemService, _) {
      var id = ModalRoute.of(context)!.settings.arguments as String?;
      var item = id != null ? itemService.itemById(id) : null;

      if (id == null || item == null) {
        return const CircularProgressIndicator();
      }
      return Scaffold(
          appBar: AppBar(
            title: const Text("Item page"),
            actions: [_deleteBtn(item, itemService, context)],
          ),
          drawer: RescueNavigationDrawer(),
          body: ItemEditPage(item));
    });
  }

  _deleteBtn(Item item, ItemService service, BuildContext context) {
    return DeleteButtonWithUsages(
        service.assignmentsFor(item).keys.map((e) => e.printName).toSet(),
        () async {
      await service.delete(item);
      Navigator.popAndPushNamed(context, routeItemsOverview);
    }, iconData: Icons.delete);
  }
}
