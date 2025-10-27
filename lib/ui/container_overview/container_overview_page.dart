import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page_card.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';
import 'package:rescuenet_warehouse/widgets/loading/data_loading_indicator.dart';
import 'package:rescuenet_warehouse/widgets/loading/error_retry_widget.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/widgets/loading/operation_loading_overlay.dart';

import '../rescue_navigation_drawer.dart';
import '../../models/rescue_container.dart';
import '../../widgets/rescue_app_bar.dart';

class ContainerOverviewPage extends river.ConsumerStatefulWidget {
  @override
  river.ConsumerState createState() => _ContainerOverviewPageState();
}

class _ContainerOverviewPageState
    extends river.ConsumerState<ContainerOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RescueAppBar(
        title: "Container overview",
        actions: [
          _createContainerButton(context, ref),
          ContainerChooserAction(),
        ],
      ),
      drawer: RescueNavigationDrawer(),
      body: _body(ref),
    );
  }

  Widget _body(river.WidgetRef ref) {
    return AsyncValueBuilder<List<RescueContainer>>(
      value: ref.watch(allContainersAsyncProvider),
      loading: () =>
          const DataLoadingIndicator(message: 'Loading containers...'),
      error: (error, stackTrace) => ErrorRetryWidget(
        error: error,
        message: 'Failed to load containers',
        onRetry: () => ref.refresh(allContainersAsyncProvider),
      ),
      data: (containers) => _buildContainerGrid(ref, containers),
    );
  }

  Widget _buildContainerGrid(
    river.WidgetRef ref,
    List<RescueContainer> containers,
  ) {
    // Filter and sort containers using the existing visibility logic
    final visibleContainers = _getVisibleContainers(ref, containers);

    if (visibleContainers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No containers found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create a new container to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: visibleContainers
            .map((c) => ContainerOverviewPageCard(c))
            .toList(),
      ),
    );
  }

  List<RescueContainer> _getVisibleContainers(
    river.WidgetRef ref,
    List<RescueContainer> allContainers,
  ) {
    // Try to use async visibility provider for proper filtering
    final visibilityAsync = ref.watch(containerVisibilityAsyncProvider);

    return visibilityAsync.when(
      data: (visibilityMap) {
        // Filter containers based on visibility map
        final visibleContainers = allContainers
            .where((container) => visibilityMap[container] == true)
            .toList();

        // Sort by container number
        visibleContainers.sort((a, b) => a.number.compareTo(b.number));
        return visibleContainers;
      },
      loading: () {
        // While visibility is loading, show all containers sorted by number
        final containers = List<RescueContainer>.from(allContainers);
        containers.sort((a, b) => a.number.compareTo(b.number));
        return containers;
      },
      error: (error, stackTrace) {
        // On error, fallback to showing all containers sorted by number
        final containers = List<RescueContainer>.from(allContainers);
        containers.sort((a, b) => a.number.compareTo(b.number));
        return containers;
      },
    );
  }

  Widget _createContainerButton(BuildContext context, river.WidgetRef ref) {
    final isCreatingContainer = ref.watch(
      isOperationLoadingProvider(DataOperation.containerCreate),
    );

    return IconButton(
      onPressed: isCreatingContainer
          ? null
          : () => _createNewContainer(context, ref),
      icon: isCreatingContainer
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
      tooltip: isCreatingContainer
          ? 'Creating container...'
          : 'Create new container',
    );
  }

  Future<void> _createNewContainer(
    BuildContext context,
    river.WidgetRef ref,
  ) async {
    try {
      // Clear any previous errors
      ref
          .read(dataOperationsNotifierProvider.notifier)
          .clearOperation(DataOperation.containerCreate);

      await context.performWithLoading<void>(
        operation: 'Creating container...',
        details: 'Setting up new container for editing',
        task: () async {
          // Create new container using async provider for proper number generation
          var container = ref
              .read(allContainersAsyncProvider.notifier)
              .newContainer();

          // Navigate to edit page with the new container ID
          if (context.mounted) {
            Navigator.pushNamed(
              context,
              routeContainerEditPage,
              arguments: container.id,
            );
          }
        },
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create container: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
