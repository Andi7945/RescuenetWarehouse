import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_with_content/container_with_content_column.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';

import '../container_chooser_action.dart';
import '../../models/rescue_container.dart';
import '../rescue_navigation_drawer.dart';
import 'container_with_content_unassigned.dart';

class ContainerWithContentPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Container with content"),
          actions: [ContainerChooserAction()],
        ),
        drawer: RescueNavigationDrawer(),
        body: AsyncValueBuilder<Map<RescueContainer, bool>>(
          value: ref.watch(containerVisibilityAsyncProvider),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading containers: ${error.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(containerVisibilityAsyncProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (visibilityMap) {
            var visible = visibilityMap.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList();
            visible.sort((a, b) => a.number.compareTo(b.number));
            return _body(visible);
          },
        ));
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
