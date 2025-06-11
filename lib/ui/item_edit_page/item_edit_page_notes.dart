import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/ui/rescue_input_text.dart';

import '../../state/current_item_notifier.dart';

class ItemEditPageNotes extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var item = ref.watch(currentItemNotifierProvider);
    if (item == null) {
      return CircularProgressIndicator();
    }

    return Container(
      width: 562,
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: RescueInputText(
                fontSize: 24,
                maxLines: 20,
                initial: item.notes,
                onChange: (s) => ref
                    .read(currentItemNotifierProvider.notifier)
                    .update(item.copyWith(notes: s))),
          ),
        ],
      ),
    );
  }
}
