import 'assignment.dart';
import 'item.dart';

var item1 = Item.filled(
    "1",
    "fire extinghuiser",
    "https://via.placeholder.com/90x81",
    "41532",
    0.7,
    2,
    "Fire extinghuiser 500 ml",
    ["Nov 30th, 2022", "Jun 30th, 2022", "Nov 30th, 2023"],
    "Deployable",
    "Fire products company",
    "FireEx",
    "600",
    "Fire & Co",
    "www.fireco.com/fireex600",
    "EUR 100,00",
    "",
    "324278",
    List.empty());

var item2 = Item.simple("2", "Folding Chair", 0.8, 13);
var item3 = Item.simple("3", "Table", 2.5, 1);
var item4 = Item.simple("4", "Generator", 18, 1);
var item5 = Item.simple("5", "Cooler", 3.4, 1);
var item6 = Item.simple("6", "Paracetamol", 0.001, 1000);
var item7 = Item.simple("7", "Splint", 0.6, 1);

var assignment_item1_container1 = Assignment("1", "1", 2);
