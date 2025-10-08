import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/all_assignments_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_edit_page/container_edit_page.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/ui/delete_button_with_usages.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';

class ContainerEditPageArgumentExtractor extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    
    // Watch loading states for different operations
    final isUpdatingContainer = ref.watch(isOperationLoadingProvider(DataOperation.containerUpdate));
    final updateError = ref.watch(getOperationErrorProvider(DataOperation.containerUpdate));
    final deleteError = ref.watch(getOperationErrorProvider(DataOperation.containerDelete));
    
    return AsyncValueBuilder<List<RescueContainer>>(
      value: ref.watch(allContainersAsyncProvider),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text("Loading...")),
        drawer: RescueNavigationDrawer(),
        body: const DataLoadingIndicator(
          message: 'Loading container information...',
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        drawer: RescueNavigationDrawer(),
        body: ErrorRetryWidget(
          error: error,
          message: 'Failed to load container information',
          onRetry: () => ref.refresh(allContainersAsyncProvider),
        ),
      ),
      data: (containers) {
        var container = containers.where((c) => c.id == containerId).firstOrNull;
        
        if (container == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Container not found")),
            drawer: RescueNavigationDrawer(),
            body: const Center(
              child: Text("Container not found"),
            ),
          );
        }
        
        return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text("Edit container ${container.number}"),
                  if (isUpdatingContainer) ...[
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saving...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              actions: [
                _deleteBtn(
                    container,
                    context,
                    ref,
                    () => _deleteContainer(context, ref, container))
              ]
            ),
            drawer: RescueNavigationDrawer(),
            body: Stack(
              children: [
                _page(container, (c) => _updateContainer(ref, c)),
                
                // Show error banners for operations
                if (updateError != null || deleteError != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        if (updateError != null)
                          ErrorBanner(
                            message: 'Failed to save container: ${updateError.toString()}',
                            onRetry: () => ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.containerUpdate),
                            onDismiss: () => ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.containerUpdate),
                          ),
                        if (deleteError != null)
                          ErrorBanner(
                            message: 'Failed to delete container: ${deleteError.toString()}',
                            onRetry: () => _retryDelete(context, ref, container),
                            onDismiss: () => ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.containerDelete),
                          ),
                      ],
                    ),
                  ),
              ],
            ));
      },
    );
  }

  _page(RescueContainer container,
      ValueChanged<RescueContainer> updateContainer) {
    var cont = ValueNotifier(container);
    cont.addListener(() {
      updateContainer(cont.value);
    });
    return ContainerEditPage(cont);
  }

  Future<void> _updateContainer(river.WidgetRef ref, RescueContainer container) async {
    try {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.containerUpdate);
      
      // Update using the data operations notifier which handles loading states
      await ref.read(dataOperationsNotifierProvider.notifier)
          .updateContainer(ContainerDao.fromContainer(container));
    } catch (error) {
      // Error will be handled by DataOperationsNotifier and shown in banner
      rethrow;
    }
  }

  Future<void> _deleteContainer(BuildContext context, river.WidgetRef ref, RescueContainer container) async {
    try {
      // Clear any previous errors
      ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.containerDelete);
      
      await context.performWithLoading<void>(
        operation: 'Deleting container...',
        details: 'Removing container ${container.number} from warehouse',
        task: () async {
          await ref.read(dataOperationsNotifierProvider.notifier)
              .deleteContainer(container.id);
        },
      );
      
      if (context.mounted) {
        Navigator.popAndPushNamed(context, routeContainerOverview);
      }
    } catch (error) {
      // Error will be handled by DataOperationsNotifier and shown in banner
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete container: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _retryDelete(BuildContext context, river.WidgetRef ref, RescueContainer container) async {
    // Clear error and retry delete operation
    ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.containerDelete);
    await _deleteContainer(context, ref, container);
  }

  _deleteBtn(RescueContainer container, BuildContext context,
      river.WidgetRef ref, Function() delete) {
    final isDeletingContainer = ref.watch(isOperationLoadingProvider(DataOperation.containerDelete));
    final assignmentsAsync = ref.watch(allAssignmentsAsyncProvider);
    
    return assignmentsAsync.when(
      loading: () => DeleteButtonWithUsages(
        <String>{}, // Empty set while loading
        null, // Disable delete while loading assignments
        iconData: Icons.hourglass_empty,
      ),
      error: (_, __) => DeleteButtonWithUsages(
        <String>{}, // Empty set on error
        null, // Disable delete on error to be safe
        iconData: Icons.error,
      ),
      data: (assignments) {
        var assigned = assignments
            .where((a) => a.containerId == container.id)
            .map((a) => a.itemId)
            .toList();
        var items = ref
            .read(allItemsNotifierProvider.notifier)
            .byIds(assigned)
            .map((itm) => itm.name ?? itm.id)
            .toSet();

        return DeleteButtonWithUsages(
          items, 
          isDeletingContainer ? null : delete,
          iconData: isDeletingContainer ? Icons.hourglass_empty : Icons.delete,
        );
      },
    );
  }
}
