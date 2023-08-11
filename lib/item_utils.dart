import 'package:rescuenet_warehouse/rescue_container.dart';

import 'item.dart';

double sumItemWeight(RescueContainer container, Iterable<Item> items) {
  return items.fold(container.type.emptyWeight,
      (prev, e) => prev + (e.weight * e.totalAmount));
}
