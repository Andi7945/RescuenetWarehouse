import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as river;
import 'package:rescuenet_warehouse/item_filter.dart';
import 'package:rescuenet_warehouse/state/items_current_filter_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import '../rescue_dropdown_button_direct.dart';
import '../rescue_input_text.dart';

class ItemFilterModal extends river.ConsumerStatefulWidget {
  const ItemFilterModal({super.key});

  @override
  river.ConsumerState createState() => _ItemFilterModalState();
}

class _ItemFilterModalState extends river.ConsumerState<ItemFilterModal> {
  @override
  Widget build(BuildContext context) => SimpleDialog(
      title: RescueText.headline("Filter items"), children: [_body()]);

  Widget _body() {
    return FractionallySizedBox(
        widthFactor: 0.5,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [_textInput(), _dropdown()]));
  }

  Widget _textInput() => SizedBox(
      width: 300,
      child: RescueInputText(
        initial: ref.watch(itemsCurrentFilterNotifierProvider).value,
        onChange: ref
            .read(itemsCurrentFilterNotifierProvider.notifier)
            .setCurrentFilterValue,
      ));

  Widget _dropdown() => RescueDropdownButtonDirect(
      _filterOptions(),
      ref.watch(itemsCurrentFilterNotifierProvider).filter,
      ref.read(itemsCurrentFilterNotifierProvider.notifier).setField);

  Map<ItemFilter, String> _filterOptions() =>
      allItemFilter.map((key, value) => MapEntry(value, value.displayName));
}
