import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/filter_fields.dart';
import 'package:rescuenet_warehouse/ui/rescue_dropdown_button_direct.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text.dart';

import '../state/container_current_filter_notifier.dart';

class ContainerFilterDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [_textInput(ref), _dropdown(context, ref)],
  );

  Widget _textInput(WidgetRef ref) => SizedBox(
    width: 300,
    child: RescueInputText(
      initial: ref.watch(containerCurrentFilterNotifierProvider).value,
      onChange: ref
          .read(containerCurrentFilterNotifierProvider.notifier)
          .setCurrentFilterValue,
    ),
  );

  Widget _dropdown(BuildContext context, WidgetRef ref) =>
      RescueDropdownButtonDirect<FilterField>(
        _filterOptions,
        ref.watch(containerCurrentFilterNotifierProvider).field,
        ref.read(containerCurrentFilterNotifierProvider.notifier).setField,
      );

  Map<FilterField, String> get _filterOptions => Map.fromEntries(
    FilterField.values.map((e) => MapEntry(e, e.displayName)),
  );
}
