import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/state/container_hidden_by_selection_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../models/rescue_container.dart';
import '../state/container_visibility_notifier.dart';
import 'container_filter_dropdown.dart';

class ContainerChooserModal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      SimpleDialog(title: RescueText.headline("Filter container"), children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ContainerFilterDropdown()]),
        _table(ref)
      ]);

  Widget _table(WidgetRef ref) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Table(columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth()
      }, children: [
        _header(),
        ..._options(ref)
      ]));

  TableRow _header() => TableRow(children: [
        Align(child: RescueText.normal("shown", FontWeight.w700)),
        RescueText.normal("name", FontWeight.w700),
        Align(child: RescueText.normal("deploy", FontWeight.w700)),
        Align(child: RescueText.normal("ready", FontWeight.w700)),
      ]);

  List<TableRow> _options(WidgetRef ref) {
    var containerWithVisible =
        ref.watch(containerVisibilityNotifierProvider).entries.toList();
    containerWithVisible.sort((a, b) => a.key.number.compareTo(b.key.number));
    return containerWithVisible
        .map((entry) => _option(MapEntry(entry.key, entry.value), ref))
        .toList();
  }

  TableRow _option(MapEntry<RescueContainer, bool> entry, WidgetRef ref) {
    s(Widget w) => _selectable(w, entry, ref);

    return TableRow(children: [
      s(_scaledCheckbox(entry.value, entry, (_) => _change(entry.key, ref))),
      s(RescueText.normal(entry.key.printName)),
      s(_scaledCheckbox(entry.key.toDeploy, entry, null)),
      s(_scaledCheckbox(entry.key.isReady, entry, null)),
    ]);
  }

  _scaledCheckbox(bool value, MapEntry<RescueContainer, bool> entry,
          ValueChanged<bool?>? onChanged) =>
      Transform.scale(
          scale: 2,
          child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: value,
              onChanged: onChanged));

  Widget _selectable(
      Widget w, MapEntry<RescueContainer, bool> entry, WidgetRef ref) {
    return InkWell(
      onTap: () => _change(entry.key, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        child: SizedBox(
            height: 40,
            child: Align(alignment: Alignment.centerLeft, child: w)),
      ),
    );
  }

  _change(RescueContainer container, WidgetRef ref) => ref
      .read(containerHiddenBySelectionNotifierProvider.notifier)
      .changeVisibility(container);
}
