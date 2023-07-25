import 'package:rescuenet_warehouse/item.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

class LogEntryExpanded {
  Item item;
  RescueContainer? container;
  int count;

  LogEntryExpanded(this.item, this.container, this.count);
}
