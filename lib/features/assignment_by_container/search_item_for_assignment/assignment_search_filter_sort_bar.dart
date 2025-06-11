import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/item_filter.dart';
import 'package:rescuenet_warehouse/measurements.dart';
import 'package:rescuenet_warehouse/models/item_sorting_options.dart';
import 'package:rescuenet_warehouse/state/items_current_filter_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_dropdown_button_direct.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text_direct.dart';

class AssignmentSearchFilterSortBar extends StatelessWidget {
  final CurrentItemFilter currentFilter;
  final Function(CurrentItemFilter) changeFilter;
  final ItemSortingOption currentSort;
  final Function(ItemSortingOption) changeSort;

  const AssignmentSearchFilterSortBar({
    super.key,
    required this.currentFilter,
    required this.changeFilter,
    required this.currentSort,
    required this.changeSort,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _textInput()),
        _dropdown(),
        kHSpacer12,
        _sort(context),
      ],
    ),
  );

  Widget _textInput() => RescueInputTextDirect(
    hintText: "Insert search term",
    initial: currentFilter.value,
    onChange: _setCurrentFilterValue,
  );

  Widget _dropdown() => RescueDropdownButtonDirect(
    _filterOptions(),
    currentFilter.filter,
    _setField,
  );

  Map<ItemFilter, String> _filterOptions() =>
      allItemFilter.map((key, value) => MapEntry(value, value.displayName));

  _setField(ItemFilter? filter) => changeFilter(
    CurrentItemFilter(
      filter: filter ?? allItemFilter.values.first,
      value: null,
    ),
  );

  _setCurrentFilterValue(String? v) =>
      changeFilter(currentFilter.copyWith(value: v));

  Widget _sort(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: PopupMenuButton(
        itemBuilder:
            (ctx) => itemSortingOptions.map((o) => _createOption(o)).toList(),
        child: Row(
          children: [
            const Icon(Icons.sort),
            Icon(_arrowIcon(currentSort.asc)),
            Text(currentSort.displayName),
          ],
        ),
      ),
    );
  }

  IconData _arrowIcon(bool asc) =>
      asc ? Icons.arrow_upward : Icons.arrow_downward;

  PopupMenuEntry _createOption(ItemSortingOption so) => PopupMenuItem(
    value: so,
    onTap: () => _changeSorting(so),
    child: Text(so.displayName),
  );

  _changeSorting(ItemSortingOption so) {
    var asc =
        currentSort.displayName == so.displayName ? !currentSort.asc : true;
    changeSort(so.copyWith(asc: asc));
  }
}
