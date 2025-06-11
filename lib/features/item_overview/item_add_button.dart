import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/state/current_item_notifier.dart';

class ItemAddButton extends ConsumerWidget {
  const ItemAddButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () async {
          ref.read(currentItemNotifierProvider.notifier).addItem();
          Navigator.pushNamed(context, routeItemEditPage);
        },
        icon: const Icon(Icons.add));
  }
}
