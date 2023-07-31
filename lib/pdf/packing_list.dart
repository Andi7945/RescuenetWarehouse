import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';

import 'packing_item.dart';

class PackingList {
  String containerNo;
  String containerType;
  String containerName;
  String containerDescription;
  double totalWeight;

  String destination;
  String sequentialBuildPrio;
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
      this.sequentialBuildPrio,
      this.expirationDate,
      this.dangerousGoods,
      this.items);
}
