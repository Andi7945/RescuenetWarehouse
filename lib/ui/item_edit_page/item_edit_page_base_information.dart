import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text.dart';
import 'package:rescuenet_warehouse/ui/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';

import '../../state/current_item_notifier.dart';

class ItemEditPageBaseInformation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var item = ref.watch(currentItemNotifierProvider);
    if (item == null) {
      return CircularProgressIndicator();
    }
    return _body(ref, item);
  }

  _body(WidgetRef ref, Item item) => Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _leftSide(ref, item)),
            Expanded(flex: 2, child: _rightSide(ref, item))
          ],
        ),
      );

  Widget _leftSide(WidgetRef ref, Item item) {
    final isUpdating = ref.watch(isOperationLoadingProvider(DataOperation.itemUpdate));
    
    return Stack(
      children: [
        RescuePickableImage(
          item.imagePath,
          isUpdating ? (_) {} : (path) => _changeItem(ref, item.copyWith(imagePath: path)),
        ),
        if (isUpdating)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(ref.context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _rightSide(WidgetRef ref, Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._widgetWithLabel("Name:", _nameInput(ref, item)),
          const SizedBox(height: 8),
          ..._widgetWithLabel("RescueNet ID:",
              RescueText.normal(item.rescueNetId.toStringAsFixed(0)))
        ],
      ),
    );
  }

  Widget _nameInput(WidgetRef ref, Item item) {
    final isUpdating = ref.watch(isOperationLoadingProvider(DataOperation.itemUpdate));
    final hasError = ref.watch(hasOperationErrorProvider(DataOperation.itemUpdate));
    
    return Stack(
      children: [
        // The existing input widget
        RescueInputText(
          fontSize: 24,
          initial: item.name,
          onChange: isUpdating 
            ? (_) {} // Disable changes when updating
            : (changed) => _changeItem(ref, item.copyWith(name: changed)),
        ),
        
        // Loading/error indicator overlay
        if (isUpdating || hasError)
          Positioned(
            top: 0,
            bottom: 0,
            right: 8,
            child: Center(
              child: isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.error_outline,
                    color: Theme.of(ref.context).colorScheme.error,
                    size: 20,
                  ),
            ),
          ),
          
        // Semi-transparent overlay when updating to show it's disabled
        if (isUpdating)
          Positioned.fill(
            child: Container(
              color: Theme.of(ref.context).colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }

  List<Widget> _widgetWithLabel(String label, Widget w) {
    return [
      RescueText.slim(label),
      const SizedBox(height: 8),
      SizedBox(height: 40, child: w)
    ];
  }

  _changeItem(WidgetRef ref, Item updated) {
    // Clear any previous update errors when making a new change
    ref.read(dataOperationsNotifierProvider.notifier).clearOperation(DataOperation.itemUpdate);
    
    // Update the item - loading states will be handled by DataOperationsNotifier
    ref.read(currentItemNotifierProvider.notifier).update(updated);
  }
}
