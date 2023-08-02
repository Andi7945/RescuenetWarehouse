import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/sequential_build.dart';

import 'packing_item.dart';

class PackingList {
  String containerNo;
  String containerType;
  String containerName;
  String containerDescription;
  double totalWeight;

  String destination;
  SequentialBuild sequentialBuild;
  DateTime? expirationDate;

  List<PackingDangerousGood> dangerousGoods;

  List<PackingItem> items;

  PackingList(
      this.containerNo,
      this.containerType,
      this.containerName,
      this.containerDescription,
      this.totalWeight,
      this.destination,
      this.sequentialBuild,
      this.expirationDate,
      this.dangerousGoods,
      this.items);
}
