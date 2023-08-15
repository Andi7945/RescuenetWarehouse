import 'package:rescuenet_warehouse/rescue_container.dart';

import 'item.dart';

double sumItemWeight(RescueContainer container, Map<Item, int> items) {
  return items.entries.fold(container.type?.emptyWeight ?? 0.0,
      (prev, e) => prev + (e.key.weight * e.value));
}
