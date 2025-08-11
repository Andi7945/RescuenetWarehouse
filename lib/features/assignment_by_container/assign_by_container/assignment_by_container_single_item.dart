import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/ui/item_card.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/widgets/loading/debounced_loading_system.dart';

import '../../../models/assignment.dart';

class AssignmentByContainerSingleItem extends ConsumerWidget {
  final Item _item;
  final Assignment _assignment;

  AssignmentByContainerSingleItem(this._item, this._assignment);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use debounced loading for assignment updates to prevent flashing
    final operationKey = 'assignment_update_${_assignment.id}';
    
    return Row(children: [_itemCard(), _assignArea(context, ref, operationKey)]);
  }

  _itemCard() {
    return Expanded(child: ItemCard(_item, _assignment.count, false));
  }

  _assignArea(BuildContext context, WidgetRef ref, String operationKey) {
    final shouldShowLoading = ref.shouldShowLoading(operationKey, config: DebouncedLoadingConfig.quick);
    final isOperationActive = ref.isOperationActive(operationKey, config: DebouncedLoadingConfig.quick);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        spacing: 8.0,
        children: [
          RescueText(56, '${_assignment.count}x'),
          Container(width: 8),
          _iconButton(context, ref, operationKey, _assignment.count - 1, Icons.exposure_minus_1, shouldShowLoading, isOperationActive),
          _iconButton(context, ref, operationKey, _assignment.count + 1, Icons.plus_one, shouldShowLoading, isOperationActive),
        ],
      ),
    );
  }

  _iconButton(BuildContext context, WidgetRef ref, String operationKey, int newCount, IconData icon, bool shouldShowLoading, bool isOperationActive) => IconButton(
    iconSize: 56,
    onPressed: isOperationActive ? null : () => _updateAssignmentCount(context, ref, operationKey, newCount),
    style: IconButton.styleFrom(
      backgroundColor: isOperationActive ? Colors.grey : Colors.blue,
    ),
    color: Colors.white,
    icon: shouldShowLoading && newCount == _assignment.count + 1
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : shouldShowLoading && newCount == _assignment.count - 1
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Icon(icon),
  );

  Future<void> _updateAssignmentCount(BuildContext context, WidgetRef ref, String operationKey, int newCount) async {
    // Use debounced loading system for the operation
    await ref.executeWithDebouncedLoading(
      operationKey: operationKey,
      config: DebouncedLoadingConfig.quick,
      operation: () async {
        // Clear any previous errors
        ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.assignmentUpdate);
        
        final updatedAssignment = _assignment.copyWith(count: newCount);
        
        // Use DataOperationsNotifier for the actual operation
        await ref.read(dataOperationsNotifierProvider.notifier)
            .upsertOrDeleteAssignment(updatedAssignment);
            
        // Show success message only if count changed significantly
        if (context.mounted && (newCount == 0 || (_assignment.count == 0 && newCount > 0))) {
          final message = newCount == 0 
              ? 'Removed ${_item.name} from container'
              : 'Added ${_item.name} to container';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    ).catchError((error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update assignment: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: () => _updateAssignmentCount(context, ref, operationKey, newCount),
              textColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        );
      }
    });
  }
}
