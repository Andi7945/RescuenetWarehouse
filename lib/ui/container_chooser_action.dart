import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';

import 'container_chooser_modal.dart';

class ContainerChooserAction extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var visible = ref.watch(containerVisibilityNotifierProvider).length;
    var all = ref.watch(allContainersNotifierProvider).length;

    return ActionChip(
        label: Row(children: [
          Text("$visible / $all"),
          const Icon(Icons.filter_alt, color: Colors.blue)
        ]),
        onPressed: () {
          showDialog(
              context: context, builder: (ctx) => ContainerChooserModal());
        });
  }
}
