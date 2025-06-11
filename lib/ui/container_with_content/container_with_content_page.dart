import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_with_content/container_with_content_column.dart';

import '../container_chooser_action.dart';
import '../../models/rescue_container.dart';
import '../rescue_navigation_drawer.dart';
import 'container_with_content_unassigned.dart';

class ContainerWithContentPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    var container = {...ref.watch(containerVisibilityNotifierProvider)};
    container.removeWhere((_, v) => !v);
    var visible = container.keys.toList();
    visible.sort((a, b) => a.number.compareTo(b.number));
    return Scaffold(
        appBar: AppBar(
          title: const Text("Container with content"),
          actions: [ContainerChooserAction()],
        ),
        drawer: RescueNavigationDrawer(),
        body: _body(visible));
  }

  Widget _body(List<RescueContainer> containers) {
    return ListView(scrollDirection: Axis.horizontal, children: [
      _asBox(ContainerWithContentUnassigned()),
      ...containers.map((e) => _asBox(ContainerWithContentColumn(e)))
    ]);
  }

  Widget _asBox(Widget w) => Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: SizedBox(width: 400, child: w));
}
