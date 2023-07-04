import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:rescuenet_warehouse/sign.dart';

import 'assignment.dart';
import 'item.dart';

var item1 = Item.filled(
    "1",
    "fire extinghuiser",
    "fire_ex.png",
    "41532",
    0.7,
    2,
    "Fire extinghuiser 500 ml",
    [
      DateTime(2022, 11, 30),
      DateTime(2022, 6, 30),
      DateTime(2023, 11, 30),
    ],
    OperationalStatus.deployable,
    "Fire products company",
    "FireEx",
    "600",
    "Fire & Co",
    "www.fireco.com/fireex600",
    "EUR 100,00",
    "",
    "324278",
    [
      Sign("DGcompressedgasses2.png"),
      Sign("coldchain.png"),
      Sign("DGcompressedgasses.png")
    ]);

var item2 = Item.simple("2", "Folding Chair", 0.8, 13,
    OperationalStatus.deployable, "folding_chair.png");
var item3 = Item.simple(
    "3", "Table", 2.5, 1, OperationalStatus.needsRepair, "folding_desk.png");
var item4 = Item.simple(
    "4", "Generator", 18, 1, OperationalStatus.needsRepair, "generator.png");
var item5 = Item.simple(
    "5", "Cooler", 3.4, 1, OperationalStatus.deployable, "cooler.png");
var item6 = Item.simple("6", "Paracetamol", 0.001, 1000,
    OperationalStatus.toBeReplaced, "paracetamol.png");
var item7 = Item.simple(
    "7", "Splint", 0.6, 1, OperationalStatus.deployable, "sam_splint.png");

var assignment_item1_container1 = Assignment("1", "1", 2);
