import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/search_item_for_assignment/assignment_search_attribute.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/search_item_for_assignment/assignment_search_filter_sort_bar.dart';
import 'package:rescuenet_warehouse/features/assignment_by_container/search_item_for_assignment/button_hide_unassignable.dart';
import 'package:rescuenet_warehouse/filter_fields.dart';
import 'package:rescuenet_warehouse/item_filter.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/item_sorting_options.dart';
import 'package:rescuenet_warehouse/state/items_current_filter_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

import 'assignment_search_item_card.dart';
import 'assignment_search_service.dart';

class AssignmentSearchItemPage extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _AssignmentSearchItemPageState();
}

class _AssignmentSearchItemPageState
    extends ConsumerState<AssignmentSearchItemPage> {
  var itemFilter = CurrentItemFilter(
    filter: allItemFilter.values.first,
    value: null,
  );
  var hideWithoutRemainingAmount = true;
  var sorting = itemSortingOptions.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RescueText(36, "Add Assignment"),
        actions: [
          ButtonHideUnassignable(
            hideWithoutRemainingAmount,
            (changed) => setState(() => hideWithoutRemainingAmount = changed),
          ),
        ],
      ),
      drawer: RescueNavigationDrawer(),
      body: _content(context),
    );
  }

  _content(BuildContext context) {
    var containerId = ModalRoute.of(context)!.settings.arguments as String;
    var items = assignableItems(
      ref,
      containerId,
      itemFilter,
      hideWithoutRemainingAmount,
      sorting,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AssignmentSearchFilterSortBar(
          currentFilter: itemFilter,
          changeFilter: (changed) => setState(() => itemFilter = changed),
          currentSort: sorting,
          changeSort: (changed) => setState(() => sorting = changed),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder:
                (ctxt, idx) => _singleCard(ctxt, items[idx].$1, items[idx].$2),
          ),
        ),
      ],
    );
  }

  Widget _singleCard(BuildContext context, Item item, int unassignedAmount) =>
      InkWell(
        onTap: () {
          Navigator.pop(context, item);
        },
        child: AssignmentSearchItemCard(
          item: item,
          amount: unassignedAmount,
          sortingField: _sortField(item),
          filterField: _filterField(item),
        ),
      );

  Widget? _filterField(Item itm) {
    if (itemFilter.value == null || itemFilter.value == "") {
      return null;
    }
    if (itemFilter.filter.displayName == FilterField.itemName.displayName) {
      return null;
    }
    return AssignmentSearchAttribute(
      label: itemFilter.filter.displayName,
      value: itemFilter.filter.value(itm) ?? "",
    );
  }

  Widget? _sortField(Item item) {
    if (sorting.displayName == FilterField.itemName.displayName) {
      return null;
    }
    if (sorting.displayName == itemFilter.filter.displayName) {
      return null;
    }

    return AssignmentSearchAttribute(
      label: sorting.displayName,
      value: sorting.value(item) ?? "",
    );
  }
}
