import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/state/data_operations_notifier.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text.dart';
import 'package:rescuenet_warehouse/ui/rescue_pickable_image.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';
import 'package:rescuenet_warehouse/widgets/loading/loading_widgets.dart';
import 'package:rescuenet_warehouse/widgets/loading/debounced_loading_system.dart';

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
        Expanded(flex: 2, child: _rightSide(ref, item)),
      ],
    ),
  );

  Widget _leftSide(WidgetRef ref, Item item) {
    // Use debounced loading for image updates (medium speed operation)
    final operationKey = 'item_image_update_${item.id}';
    final shouldShowLoading = ref.shouldShowLoading(
      operationKey,
      config: DebouncedLoadingConfig.medium,
    );
    final isOperationActive = ref.isOperationActive(
      operationKey,
      config: DebouncedLoadingConfig.medium,
    );

    return Stack(
      children: [
        RescuePickableImage(
          item.imagePath,
          isOperationActive
              ? (_) {}
              : (path) => _changeItemWithDebounce(
                  ref,
                  item.copyWith(imagePath: path),
                  operationKey,
                ),
        ),
        if (shouldShowLoading)
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
          ..._widgetWithLabel(
            "RescueNet ID:",
            RescueText.normal(item.rescueNetId.toStringAsFixed(0)),
          ),
        ],
      ),
    );
  }

  Widget _nameInput(WidgetRef ref, Item item) {
    // Use debounced loading for name updates (quick operation - typing)
    final operationKey = 'item_name_update_${item.id}';
    final shouldShowLoading = ref.shouldShowLoading(
      operationKey,
      config: DebouncedLoadingConfig.quick,
    );
    final isOperationActive = ref.isOperationActive(
      operationKey,
      config: DebouncedLoadingConfig.quick,
    );
    final hasError = ref.watch(
      hasOperationErrorProvider(DataOperation.itemUpdate),
    );

    return Stack(
      children: [
        // The existing input widget
        RescueInputText(
          fontSize: 24,
          initial: item.name,
          onChange: isOperationActive
              ? (_) {} // Disable changes when updating
              : (changed) => _changeItemWithDebounce(
                  ref,
                  item.copyWith(name: changed),
                  operationKey,
                ),
        ),

        // Loading/error indicator overlay
        if (shouldShowLoading || hasError)
          Positioned(
            top: 0,
            bottom: 0,
            right: 8,
            child: Center(
              child: shouldShowLoading
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
        if (isOperationActive)
          Positioned.fill(
            child: Container(
              color: Theme.of(
                ref.context,
              ).colorScheme.surface.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }

  List<Widget> _widgetWithLabel(String label, Widget w) {
    return [
      RescueText.slim(label),
      const SizedBox(height: 8),
      SizedBox(height: 40, child: w),
    ];
  }

  _changeItem(WidgetRef ref, Item updated) {
    // Clear any previous update errors when making a new change
    ref
        .read(dataOperationsNotifierProvider.notifier)
        .clearOperation(DataOperation.itemUpdate);

    // Update the item - loading states will be handled by DataOperationsNotifier
    ref.read(currentItemNotifierProvider.notifier).update(updated);
  }

  /// Change item with debounced loading feedback
  void _changeItemWithDebounce(
    WidgetRef ref,
    Item updated,
    String operationKey,
  ) {
    // Use the debounced loading system for UI feedback
    ref
        .executeWithDebouncedLoading(
          operationKey: operationKey,
          config: operationKey.contains('name')
              ? DebouncedLoadingConfig.quick
              : DebouncedLoadingConfig.medium,
          operation: () async {
            // Clear any previous update errors when making a new change
            ref
                .read(dataOperationsNotifierProvider.notifier)
                .clearOperation(DataOperation.itemUpdate);

            // Update the item - this will trigger the actual save operation
            ref.read(currentItemNotifierProvider.notifier).update(updated);

            // Add a small delay to simulate the save operation for demo purposes
            // In real usage, this would be handled by the repository/notifier
            await Future.delayed(const Duration(milliseconds: 50));
          },
        )
        .catchError((error) {
          // Error handling is already managed by the existing error system
          debugPrint('Item update error: $error');
        });
  }
}
