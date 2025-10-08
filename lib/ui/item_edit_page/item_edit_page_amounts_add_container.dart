import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/state/current_item_assignments_notifier.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

import '../../state/all_containers_notifier.dart';
import '../rescue_dropdown_button.dart';
import '../rescue_text.dart';

class ItemEditPageAmountsAddContainer extends river.ConsumerStatefulWidget {
  final Set<RescueContainer> haveBeenUsed;

  ItemEditPageAmountsAddContainer(this.haveBeenUsed);

  @override
  river.ConsumerState createState() => _ItemEditPageAmountsAddContainerState();
}

class _ItemEditPageAmountsAddContainerState
    extends river.ConsumerState<ItemEditPageAmountsAddContainer> {
  ValueNotifier<String> valueNotifier = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(height: 8),
            Text(
              'Failed to load containers',
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
      data: (containers) {
        var availableOptions =
            containers.where((c) => !widget.haveBeenUsed.contains(c)).toList();
        return _body(_options(availableOptions));
      },
    );
  }

  Map<String, String> _options(List<RescueContainer> availableOptions) {
    return SplayTreeMap<RescueContainer, String>.fromIterable(availableOptions,
            key: (e) => e,
            value: (e) => e.printName,
            compare: (a, b) => a.number.compareTo(b.number))
        .map((key, value) => MapEntry(key.id, value));
  }

  @override
  void initState() {
    super.initState();

    valueNotifier.addListener(() {
      setState(() {});
    });
  }

  _body(Map<String, String> otherContainerOptions) {
    if (otherContainerOptions.isEmpty) {
      return RescueText.slim("No new containers available");
    }
    return _containerSelector(otherContainerOptions);
  }

  _containerSelector(Map<String, String> otherContainerOptions) {
    if (otherContainerOptions[valueNotifier.value] == null) {
      valueNotifier.dispose();
      var options = otherContainerOptions.entries.first;
      valueNotifier = _newListener(options.key);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      RescueDropdownButton(otherContainerOptions, valueNotifier),
      IconButton(
          onPressed: () => _addNewContainer(valueNotifier.value),
          icon: const Icon(Icons.add))
    ]);
  }

  _addNewContainer(String containerIdToAdd) => ref
      .read(currentItemAssignmentsNotifierProvider.notifier)
      .addContainerAssignment(containerIdToAdd, 1);

  _newListener(String selectedValue) {
    ValueNotifier<String> valueNotifier = ValueNotifier(selectedValue);
    valueNotifier.addListener(() {
      setState(() {});
    });
    return valueNotifier;
  }
}
