import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/state/container_with_items_notifier.dart';
import 'package:rescuenet_warehouse/features/printing/ui/export_actions.dart';

import '../../models/item.dart';
import '../../models/rescue_container.dart';
import '../rescue_text.dart';
import '../rescue_navigation_drawer.dart';
import '../../widgets/rescue_app_bar.dart';
import 'export_page_body.dart';

class ExportPage extends river.ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  river.ConsumerState createState() => _ExportPageState();
}

class _ExportPageState extends river.ConsumerState<ExportPage> {
  @override
  Widget build(BuildContext context) {
    var allContainersWithItems = ref.watch(containerWithItemsNotifierProvider);
    return Scaffold(
        appBar: RescueAppBar(
            title: "Ready containers",
            actions: [_summaryButton(allContainersWithItems)]),
        drawer: RescueNavigationDrawer(),
        body: ExportPageBody(allContainersWithItems));
  }

  Widget _summaryButton(
          Map<RescueContainer, Map<Item, int>> allContainersWithItems) =>
      ActionChip(
          onPressed: () async {
            await _shareSummaryPdf(allContainersWithItems);
          },
          label: RescueText.slim("Print final summary"));

  Future<void> _shareSummaryPdf(
    Map<RescueContainer, Map<Item, int>> withItems,
  ) async {
    final forContainers = Map.fromEntries(
      withItems.entries.where((ele) => ele.key.isReady && ele.key.toDeploy),
    );

    await ExportActions.handleSummary(context, ref, forContainers);
  }
}
