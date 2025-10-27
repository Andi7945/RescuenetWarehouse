import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/container_visibility_notifier.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';
import 'package:rescuenet_warehouse/ui/container_chooser_action.dart';
import 'package:rescuenet_warehouse/ui/container_overview/container_overview_page_card_content.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/widgets/loading/async_value_builder.dart';
import 'package:rescuenet_warehouse/widgets/loading/data_loading_indicator.dart';
import 'package:rescuenet_warehouse/widgets/loading/error_retry_widget.dart';
import 'package:rescuenet_warehouse/widgets/rescue_app_bar.dart';

class ContainerAssignmentsPage extends river.ConsumerWidget {
  @override
  Widget build(BuildContext context, river.WidgetRef ref) {
    return Scaffold(
      appBar: RescueAppBar(
        title: "Choose container to assign items to",
        actions: [ContainerChooserAction()],
      ),
      drawer: RescueNavigationDrawer(),
      body: _body(ref, context),
    );
  }

  Widget _body(river.WidgetRef ref, BuildContext context) {
    return AsyncValueBuilder<List<RescueContainer>>(
      value: ref.watch(allContainersAsyncProvider),
      loading: () =>
          const DataLoadingIndicator(message: 'Loading containers...'),
      error: (error, stackTrace) => ErrorRetryWidget(
        error: error,
        message: 'Failed to load containers',
        onRetry: () => ref.refresh(allContainersAsyncProvider),
      ),
      data: (containers) => _buildContainerSelection(ref, context, containers),
    );
  }

  Widget _buildContainerSelection(
    river.WidgetRef ref,
    BuildContext context,
    List<RescueContainer> containers,
  ) {
    final visibleContainers = _getVisibleContainers(ref, containers);

    if (visibleContainers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No containers available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create a container first to assign items',
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
            .map<Widget>((c) => _containerCard(c, context))
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

  Widget _containerCard(RescueContainer container, BuildContext context) {
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
