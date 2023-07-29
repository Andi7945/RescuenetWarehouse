import 'package:rescuenet_warehouse/pdf/packing_dangerous_good.dart';
import 'package:rescuenet_warehouse/pdf/packing_item.dart';
import 'package:rescuenet_warehouse/pdf/packing_list.dart';
import 'package:rescuenet_warehouse/pdf/summary_container.dart';

var summaryContainer = [
  SummaryContainer(
      "1",
      "Office supplies",
      "Printer, tables, etc.",
      "Euro 60-40-32",
      480,
      29.5,
      "May 5th, 2023",
      "Aerosol, non-flammable",
      "",
      "Office",
      "First build"),
  SummaryContainer("2", "Cooler", "With cold packs and meds", "Cooler", 540, 12,
      "Dec 12th, 2023", "", "Yes", "Storage", "Pre build"),
  SummaryContainer("3", "Fridge", "Electrical fridge", "Euro 60-40-32", 300, 20,
      "", "", "Yes", "Storage", "Pre build"),
  SummaryContainer("4", "Tents", "Meeting tent", "Euro 60-40-32", 300, 31, "",
      "", "", "Meeting area", "Later build"),
  SummaryContainer("5", "Sanitation", "Toilets, shower", "Euro 60-40-32", 300,
      25, "", "", "", "Meeting area", "First build"),
  SummaryContainer("6", "Water filter 1", "Water filter for base camp",
      "Euro 60-40-32", 300, 28.5, "", "", "", "Water treatment", "Later build"),
  SummaryContainer(
      "7",
      "Water raw storage",
      "Storage 3800 liter raw water base camp",
      "Euro 60-40-32",
      300,
      20,
      "",
      "",
      "",
      "Water treatment",
      "Later build"),
  SummaryContainer("8", "Power 1", "For fridge", "Euro 60-40-32", 300, 30.5, "",
      "Flammable liquid Aerosol, non-flammable", "Yes", "Storage", "Pre build"),
  SummaryContainer("9", "Medical backpack 1", "", "Medical backpack", 300, 18.5,
      "March 20th, 2024", "", "", "Storage", "Storage supply"),
];

var packingList = PackingList(
    "1",
    "Euro L60xW40xH32",
    "Office supplies",
    "Printer, tables, etc,",
    20.5,
    "Office",
    "First Build",
    DateTime(2023, 5),
    [packingDangerousGood],
    [packingItem1, packingItem2, packingItem3]);

var packingDangerousGood = PackingDangerousGood(
    "Compressed gasses",
    "2.2 / 1950",
    "Aerosol, non-flammable",
    0.5,
    2.0,
    "Limited quantities LQ2",
    "DGcompressedgasses.png");

var packingItem1 = PackingItem(
    "Folding chair", "", 13, 15, 12.2, DateTime(2023, 5, 5), "", "");

var packingItem2 = PackingItem("Table", "", 1, 75, 2.5, null, "", "");

var packingItem3 = PackingItem(
    "Fire Extinguisher",
    "FireEx 600 Airline safe aerogel cans",
    2,
    100,
    1.4,
    null,
    "2.2 / 1950",
    "Limited quantities LQ2");
