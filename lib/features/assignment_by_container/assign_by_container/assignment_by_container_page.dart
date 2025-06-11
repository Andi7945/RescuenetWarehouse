import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_header.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_items.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_state.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../../../models/rescue_container.dart';

class AssignmentByContainerPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    var container = ref
        .watch(allContainersNotifierProvider.notifier)
        .byId(containerId);
    if (container == null) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(title: Text("Assign items to ${container.printName}")),
      drawer: RescueNavigationDrawer(),
      body: _page(context, container, ref),
    );
  }

  _page(BuildContext context, RescueContainer container, ref) {
    return ListView(
      shrinkWrap: true,
      children: [
        AssignmentByContainerHeader(container),
        _assignmentsTitle(),
        AssignmentByContainerItems(container),
        _addButton(context, container, ref),
      ],
    );
  }

  _assignmentsTitle() => Padding(
    padding: EdgeInsets.all(8.0),
    child: Center(child: RescueText(24, "Assignments")),
  );

  _addButton(context, RescueContainer container, ref) => Padding(
    padding: EdgeInsets.all(16.0),
    child: IconButton(
      color: Colors.white,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      iconSize: 72,
      onPressed: () {
        var result = Navigator.pushNamed(
          context,
          routeContainerAssignmentSearchItemPage,
          arguments: container.id,
        );
        result.then((i) => _addItem(container, i, ref));
      },
      icon: Icon(Icons.add),
    ),
  );

  _addItem(RescueContainer container, Object? item, river.WidgetRef ref) {
    if (item == null || item is! Item) {
      print("No item selected. Doing nothing.");
      return;
    }
    ref
        .read(assignmentByContainerStateProvider(container.id).notifier)
        .addItem(container.id, item);
    print("Added item ${item.name} to container ${container.name}");
  }
}
