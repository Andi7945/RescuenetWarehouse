import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page_card.dart';
import 'package:rescuenet_warehouse/routes.dart';

import '../rescue_navigation_drawer.dart';

class ContainerOverviewPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Container overview"),
          actions: [
            IconButton(
                onPressed: () {
                  var cont = ref
                      .read(allContainersNotifierProvider.notifier)
                      .newContainer();
                  Navigator.pushNamed(context, routeContainerEditPage,
                      arguments: cont.id);
                },
                icon: const Icon(Icons.add)),
            ContainerChooserAction(),
          ],
        ),
        drawer: RescueNavigationDrawer(),
        body: _body(ref));
  }

  _body(river.WidgetRef ref) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(spacing: 4.0, runSpacing: 4.0, children: [
        ..._sorted(ref).map((c) => ContainerOverviewPageCard(c))
      ]));

  _sorted(river.WidgetRef ref) {
    var containersWithVisibility = {
      ...ref.watch(containerVisibilityNotifierProvider)
    };
    containersWithVisibility.removeWhere((key, value) => !value);
    var containers = containersWithVisibility.keys.toList();
    containers.sort((a, b) => a.number.compareTo(b.number));
    return containers;
  }
}
