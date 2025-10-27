import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/state/all_containers_notifier.dart';

import '../rescue_text.dart';

class ContainerWithContentHeaderCheckbox extends ConsumerWidget {
  final String label;
  final bool value;
  final RescueContainer Function(bool) provideChanged;

  ContainerWithContentHeaderCheckbox(
    this.label,
    this.value,
    this.provideChanged,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RescueText(20, label, textAlign: TextAlign.center),
          _checkbox(ref),
        ],
      ),
    );
  }

  _checkbox(WidgetRef ref) {
    return Transform.scale(
      scale: 2.5,
      child: Checkbox(
        value: value,
        onChanged: (bool? value) {
          ref
              .read(allContainersAsyncProvider.notifier)
              .updateContainer(provideChanged(value ?? false));
        },
      ),
    );
  }
}
