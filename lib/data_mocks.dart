import 'package:rescuenet_warehouse/container_type.dart';
import 'package:rescuenet_warehouse/operational_status.dart';
import 'package:rescuenet_warehouse/sequential_build.dart';
import 'package:rescuenet_warehouse/sign.dart';

import 'assignment.dart';
import 'container_dao.dart';
import 'item.dart';
import 'main.dart';

var item_fire = Item.filled(
    "1",
    "fire extinghuiser",
    "fire_ex.png",
    41532,
    0.7,
    8,
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
    100,
    "",
    "324278",
    false,
    "Remark it!",
    [
      Sign.filled(
          id: uuid.v4(),
          unNumber: "12.689",
          imagePath: "DGcompressedgasses2.png",
          instructions: "Take care",
          remarks: "Remarkable",
          sdsPath: "/path/",
          dangerType: "gas",
          properShippingName: "Flammable",
          maxWeightPAX: 0.5,
          maxWeightCargo: 2.0),
      Sign.filled(
          id: uuid.v4(),
          unNumber: "213 / 17",
          imagePath: "DGcompressedgasses.png",
          instructions: "Take great care",
          remarks: "Remarkable2",
          sdsPath: "/path/2",
          dangerType: "gas",
          properShippingName: "Aerosol",
          maxWeightPAX: 1.0,
          maxWeightCargo: 2.7),
    ]);

var item_chair = Item.simple("2", "Folding Chair", 0.8, 13,
    OperationalStatus.deployable, "folding_chair.png", 10000);
var item_desk = Item.simple("3", "Table", 2.5, 1, OperationalStatus.needsRepair,
    "folding_desk.png", 10001);
var item_generator = Item.simple("4", "Generator", 18, 1,
    OperationalStatus.needsRepair, "generator.png", 10002);
var item_cooler = Item.simple("5", "Cooler", 3.4, 1,
    OperationalStatus.deployable, "cooler.png", 10003, true);
var item_para = Item.simple("6", "Paracetamol", 0.001, 1000,
    OperationalStatus.toBeReplaced, "paracetamol.png", 10004);
var item_splint = Item.simple("7", "Splint", 0.6, 1,
    OperationalStatus.deployable, "sam_splint.png", 10005);

var assignment_item1_container1 = Assignment("1", "1", "1", 2);
var assignment_item1_container3 = Assignment("2", "1", "3", 4);

var container_office = ContainerDao(
    "1",
    1,
    "Office supplies",
    "Tables, Chairs, etc.",
    container_type_crate.id,
    SequentialBuild.firstBuild,
    "1",
    "1",
    true,
    false);
var container_power = ContainerDao("2", 2, "Power", "Power supplies",
    container_type_crate.id, SequentialBuild.laterBuild, "1", "2", true, true);
var container_medical = ContainerDao(
    "3",
    3,
    "Medical backpack team 1",
    "Med stuff",
    container_type_backpack.id,
    SequentialBuild.supplies,
    "2",
    "1",
    true,
    true);

var container_type_crate =
    ContainerType("1", "Euro crate", "euro_crate.png", 1.7, "60x40x40");
var container_type_backpack = ContainerType(
    "2", "Medical backpack", "medical_backpack.png", 0.5, "60x40x32");
