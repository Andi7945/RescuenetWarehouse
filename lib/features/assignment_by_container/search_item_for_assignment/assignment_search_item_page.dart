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
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_navigation_drawer.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

import 'assignment_search_item_card.dart';
import 'assignment_search_service.dart';
import '../../../widgets/rescue_app_bar.dart';

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
    return Consumer(
      builder: (context, ref, child) {
        // Watch loading state for assignment creation
        final isCreatingAssignment = ref.watch(
          isOperationLoadingProvider(DataOperation.assignmentCreate),
        );

        return Scaffold(
          appBar: RescueAppBar(
            title: Row(
              children: [
                RescueText(36, "Add Assignment"),
                if (isCreatingAssignment) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assigning...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            actions: [
              ButtonHideUnassignable(
                hideWithoutRemainingAmount,
                (changed) =>
                    setState(() => hideWithoutRemainingAmount = changed),
              ),
            ],
          ),
          drawer: RescueNavigationDrawer(),
          body: _content(context, isCreatingAssignment),
        );
      },
    );
  }

  _content(BuildContext context, bool isCreatingAssignment) {
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
      children: [
        AssignmentSearchFilterSortBar(
          currentFilter: itemFilter,
          changeFilter: (changed) => setState(() => itemFilter = changed),
          currentSort: sorting,
          changeSort: (changed) => setState(() => sorting = changed),
        ),
        Expanded(
          child: AbsorbPointer(
            absorbing: isCreatingAssignment,
            child: Opacity(
              opacity: isCreatingAssignment ? 0.6 : 1.0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (ctxt, idx) => _singleCard(
                  ctxt,
                  items[idx].$1,
                  items[idx].$2,
                  isCreatingAssignment,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _singleCard(
    BuildContext context,
    Item item,
    int unassignedAmount,
    bool isCreatingAssignment,
  ) => InkWell(
    onTap: isCreatingAssignment ? null : () => _selectItem(context, item),
    child: Container(
      decoration: isCreatingAssignment
          ? BoxDecoration(color: Colors.grey.withOpacity(0.1))
          : null,
      child: AssignmentSearchItemCard(
        item: item,
        amount: unassignedAmount,
        sortingField: _sortField(item),
        filterField: _filterField(item),
      ),
    ),
  );

  Future<void> _selectItem(BuildContext context, Item item) async {
    try {
      await context.performWithLoading<void>(
        operation: 'Selecting item...',
        details: 'Preparing to assign ${item.name}',
        task: () async {
          // Small delay to show the loading indicator
          await Future.delayed(const Duration(milliseconds: 500));
        },
      );

      if (context.mounted) {
        Navigator.pop(context, item);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select item: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

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
