import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/current_item_assignments_not_null_notifier.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';

class ItemEditPageArgumentExtractor extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Item page"),
          actions: [_deleteBtn(context, ref)],
        ),
        drawer: RescueNavigationDrawer(),
        body: ItemEditPage());
  }

  _deleteBtn(BuildContext context, river.WidgetRef ref) {
    var currentAssignments = ref
        .watch(currentItemAssignmentsNotNullNotifierProvider)
        .keys
        .map((e) => e.printName)
        .toSet();
    var currentItem = ref.watch(currentItemNotifierProvider.notifier);

    return DeleteButtonWithUsages(currentAssignments, () async {
      currentItem.delete();
      Navigator.popAndPushNamed(context, routeItemsOverview);
    }, iconData: Icons.delete);
  }
}
