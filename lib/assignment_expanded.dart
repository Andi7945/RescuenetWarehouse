import 'package:rescuenet_warehouse/rescue_container.dart';

import 'item.dart';

class AssignmentExpanded {
  final String id;
  final Item item;
  final RescueContainer container;
  final int count;

  AssignmentExpanded(this.id, this.item, this.container, this.count);
}