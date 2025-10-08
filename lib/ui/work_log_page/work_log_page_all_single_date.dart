import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/all_items_notifier.dart';
import 'package:rescuenet_warehouse/ui/work_log_page/work_log_page_entry.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

import '../../models/log_entry_summed.dart';
import '../../state/all_containers_notifier.dart';
import '../rescue_text.dart';

class WorkLogPageAllSingleDate extends ConsumerWidget {
  final List<LogEntrySummed> entries;

  const WorkLogPageAllSingleDate({super.key, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var containerId = entries.firstOrNull?.containerId;
    if (containerId == null) {
      return Container();
    }
    
    return ref.watch(allContainersAsyncProvider).when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(height: 8),
              Text(
                'Failed to load container information',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(allContainersAsyncProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (containers) {
        var container = containers.where((c) => c.id == containerId).firstOrNull;
        return table(container?.printName, ref);
      },
    );
  }

  Widget table(String? containerName, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 24, left: 8, right: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RescueText.headline("Container: ${containerName ?? ""}")),
          Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [header(), ...entries.map((x) => _singleItem(x, ref))])
        ]));
  }

  TableRow _singleItem(LogEntrySummed sum, WidgetRef ref) {
    var itm = ref.watch(allItemsNotifierProvider.notifier).byId(sum.itemId);
    return item(itm?.name, sum.count, sum.user);
  }
}
