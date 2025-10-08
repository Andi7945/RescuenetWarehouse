import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';

import 'container_chooser_modal.dart';

class ContainerChooserAction extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(containerVisibilityAsyncProvider).when(
      loading: () => ref.watch(allContainersAsyncProvider).when(
        loading: () => ActionChip(
          label: const Row(children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Icon(Icons.filter_alt, color: Colors.blue)
          ]),
          onPressed: null, // Disable while loading
        ),
        error: (error, stackTrace) => ActionChip(
          label: const Row(children: [
            Icon(Icons.error_outline, color: Colors.red, size: 16),
            SizedBox(width: 4),
            Text("Error"),
            SizedBox(width: 4),
            Icon(Icons.filter_alt, color: Colors.blue)
          ]),
          onPressed: () {
            showDialog(
                context: context, builder: (ctx) => ContainerChooserModal());
          },
        ),
        data: (containers) => ActionChip(
          label: const Row(children: [
            Text("Loading..."),
            SizedBox(width: 4),
            Icon(Icons.filter_alt, color: Colors.blue)
          ]),
          onPressed: () {
            showDialog(
                context: context, builder: (ctx) => ContainerChooserModal());
          },
        ),
      ),
      error: (error, stackTrace) => ActionChip(
        label: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red, size: 16),
          SizedBox(width: 4),
          Text("Error"),
          SizedBox(width: 4),
          Icon(Icons.filter_alt, color: Colors.blue)
        ]),
        onPressed: () {
          showDialog(
              context: context, builder: (ctx) => ContainerChooserModal());
        },
      ),
      data: (visibilityMap) => ref.watch(allContainersAsyncProvider).when(
        loading: () => ActionChip(
          label: const Row(children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Icon(Icons.filter_alt, color: Colors.blue)
          ]),
          onPressed: null,
        ),
        error: (error, stackTrace) => ActionChip(
          label: const Row(children: [
            Icon(Icons.error_outline, color: Colors.red, size: 16),
            SizedBox(width: 4),
            Text("Error"),
            SizedBox(width: 4),
            Icon(Icons.filter_alt, color: Colors.blue)
          ]),
          onPressed: () {
            showDialog(
                context: context, builder: (ctx) => ContainerChooserModal());
          },
        ),
        data: (containers) {
          var visible = visibilityMap.values.where((v) => v).length;
          var all = containers.length;
          
          return ActionChip(
              label: Row(children: [
                Text("$visible / $all"),
                const Icon(Icons.filter_alt, color: Colors.blue)
              ]),
              onPressed: () {
                showDialog(
                    context: context, builder: (ctx) => ContainerChooserModal());
              });
        },
      ),
    );
  }
}
