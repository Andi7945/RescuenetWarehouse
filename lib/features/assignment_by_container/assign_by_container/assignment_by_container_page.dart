import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_header.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_items.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/assign_by_container/assignment_by_container_state.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

import '../../../models/rescue_container.dart';

class AssignmentByContainerPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    var container = ref
        .watch(allContainersNotifierProvider.notifier)
        .byId(containerId);
        
    // Watch loading state for assignment creation
    final isCreatingAssignment = ref.watch(isOperationLoadingProvider(DataOperation.assignmentCreate));
    
    if (container == null) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(title: Text("Assign items to ${container.printName}")),
      drawer: RescueNavigationDrawer(),
      body: _page(context, container, ref, isCreatingAssignment),
    );
  }

  _page(BuildContext context, RescueContainer container, river.WidgetRef ref, bool isCreatingAssignment) {
    return ListView(
      shrinkWrap: true,
      children: [
        AssignmentByContainerHeader(container),
        _assignmentsTitle(),
        AssignmentByContainerItems(container),
        _addButton(context, container, ref, isCreatingAssignment),
      ],
    );
  }

  _assignmentsTitle() => Padding(
    padding: EdgeInsets.all(8.0),
    child: Center(child: RescueText(24, "Assignments")),
  );

  _addButton(context, RescueContainer container, river.WidgetRef ref, bool isCreatingAssignment) => Padding(
    padding: EdgeInsets.all(16.0),
    child: IconButton(
      color: Colors.white,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCreatingAssignment ? Colors.grey : Colors.blue,
      ),
      iconSize: 72,
      onPressed: isCreatingAssignment ? null : () => _navigateToSearchPage(context, container, ref),
      icon: isCreatingAssignment
          ? const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            )
          : const Icon(Icons.add),
    ),
  );

  Future<void> _navigateToSearchPage(BuildContext context, RescueContainer container, river.WidgetRef ref) async {
    var result = await Navigator.pushNamed(
      context,
      routeContainerAssignmentSearchItemPage,
      arguments: container.id,
    );
    
    if (context.mounted) {
      await _addItem(context, container, result, ref);
    }
  }

  Future<void> _addItem(BuildContext context, RescueContainer container, Object? item, river.WidgetRef ref) async {
    if (item == null || item is! Item) {
      print("No item selected. Doing nothing.");
      return;
    }

    try {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.assignmentCreate);
      
      await context.performWithLoading<void>(
        operation: 'Adding item to container...',
        details: 'Creating assignment for ${item.name}',
        task: () async {
          await ref
              .read(assignmentByContainerStateProvider(container.id).notifier)
              .addItem(container.id, item);
        },
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added ${item.name} to ${container.printName}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      print("Added item ${item.name} to container ${container.name}");
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${item.name}: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: () => _addItem(context, container, item, ref),
              textColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        );
      }
    }
  }
}
