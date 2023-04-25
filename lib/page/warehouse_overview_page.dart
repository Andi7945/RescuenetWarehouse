import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/single_rn_item_model.dart';
import '../provider/rn_items_provider.dart';
import '../widget/horizontal_drag_widget.dart';
import '../widget/single_rn_box_widget.dart';
import '../widget/single_rn_item_widget.dart';


class WareHouseOverviewPage extends StatefulWidget {
  const WareHouseOverviewPage({Key? key}) : super(key: key);
  static const routeName = '/warehouseOverview';

  @override
  State<WareHouseOverviewPage> createState() => _WareHouseOverviewPageState();
}

class _WareHouseOverviewPageState extends State<WareHouseOverviewPage> {
  int viewMode = 0;
  List<InnerList> _lists = [];


  @override
  Widget build(BuildContext context) {

    RNItemsProvider rnItemsProvider =
    Provider.of<RNItemsProvider>(context, listen: true);
    List<SingleRNItemModel> all_items = rnItemsProvider.rnItems;
    List<SingleRNItemModel> boxes = [
      SingleRNItemModel(id: "1", name: "Unsorted"),
    ];
    boxes.addAll(rnItemsProvider.rnBoxes);
    print("Anzahl der Boxen:${boxes.length}");
    print("Anzahl der Items:${all_items.length}");

    _lists = List.generate(boxes.length, (outerIndex) {
      if (outerIndex == 0) {
        return InnerList(
          box: boxes[outerIndex],
          children: [],
          weight: 0,
        );
      }
      final list = List.generate(
          boxes[outerIndex].contains.length,
              (innerIndex) => all_items.firstWhere((element) =>
          element.id == boxes[outerIndex].contains[innerIndex]));
      final double weight = list.fold(0, (previousValue, element) => previousValue + ((element.weight ?? 0) * element.amount));

      return InnerList(box: boxes[outerIndex], weight: weight, children: list);
    });

    List<SingleRNItemModel> remainingItems = List.from(all_items);
    for (int i = 0; i < _lists.length; i++) {
      for (int j = 0; j < _lists[i].children.length; j++) {
        remainingItems.remove(_lists[i].children[j]);
      }
    }
    _lists[0].children = remainingItems;


    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Warehouse'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  viewMode = 0;
                });
              },
              child: const Text("Boxes with content"),
            ),
            const SizedBox(
              width: 15,),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  viewMode = 1;
                });
              },
              child: const Text("Boxes"),
            ),
            const SizedBox(
              width: 15,),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  viewMode = 2;
                });
              },
              child: const Text("Items"),
            ),
            const SizedBox(
              width: 15,),
          ],
        ),
      ),
      drawer: const NavigationDrawer(
        children: [],
      ),
      body: viewMode == 0 ? HorizontalDragWidget(lists: _lists,) :
      viewMode == 2 ?
        Wrap(
          children: List.generate(all_items.length, (index) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              width: 265,
              height: 140,
              child: SingleRNItemWidget(
                id: all_items[index].id,
              ),
            );
          }))
      : Wrap(
          children: List.generate(all_items.length, (index) {
            if(index == 0) return Container();
            return Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 300,
              height: 200,
              child: SingleRNBoxWidget(
                id: boxes[index].id, position: index,
                wight: _lists[index].weight,
              ),
            );
          })),
    );
  }
}
