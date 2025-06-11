import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page_card_content.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';

class ContainerAssignmentsPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose container to assign items to"),
        actions: [ContainerChooserAction()],
      ),
      drawer: RescueNavigationDrawer(),
      body: _body(ref, context),
    );
  }

  _body(river.WidgetRef ref, BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: [..._sorted(ref).map((c) => _containerCard(c, context))],
    ),
  );

  _sorted(river.WidgetRef ref) {
    var containersWithVisibility = {
      ...ref.watch(containerVisibilityNotifierProvider),
    };
    containersWithVisibility.removeWhere((key, value) => !value);
    var containers = containersWithVisibility.keys.toList();
    containers.sort((a, b) => a.number.compareTo(b.number));
    return containers;
  }

  _containerCard(RescueContainer container, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          routeContainerAssignmentSinglePage,
          arguments: container.id,
        );
      },
      child: ContainerOverviewPageCardContent(container, 410),
    );
  }
}
