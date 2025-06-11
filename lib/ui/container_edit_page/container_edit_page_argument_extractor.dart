import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_edit_page/container_edit_page.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';

class ContainerEditPageArgumentExtractor extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    var container =
        ref.watch(allContainersNotifierProvider.notifier).byId(containerId);
    if (container == null) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
        appBar:
            AppBar(title: Text("Edit container ${container.number}"), actions: [
          _deleteBtn(
              container,
              context,
              ref,
              () => ref
                  .read(allContainersNotifierProvider.notifier)
                  .delete(container))
        ]),
        drawer: RescueNavigationDrawer(),
        body: _page(container,
            (c) => ref.read(allContainersNotifierProvider.notifier).update(c)));
  }

  _page(RescueContainer container,
      ValueChanged<RescueContainer> updateContainer) {
    var cont = ValueNotifier(container);
    cont.addListener(() {
      updateContainer(cont.value);
    });
    return ContainerEditPage(cont);
  }

  _deleteBtn(RescueContainer container, BuildContext context,
      river.WidgetRef ref, Function() delete) {
    var assigned = ref
        .read(allAssignmentsNotifierProvider.notifier)
        .byContainer(container.id)
        .map((a) => a.itemId)
        .toList();
    var items = ref
        .read(allItemsNotifierProvider.notifier)
        .byIds(assigned)
        .map((itm) => itm.name ?? itm.id)
        .toSet();
    return DeleteButtonWithUsages(items, () async {
      // delete();
      Navigator.popAndPushNamed(context, routeContainerOverview);
    }, iconData: Icons.delete);
  }
}
