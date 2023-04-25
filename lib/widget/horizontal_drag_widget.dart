import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/widget/single_rn_box_widget.dart';
import 'package:rescuenet_warehouse/widget/single_rn_item_widget.dart';

import '../model/single_rn_item_model.dart';
import '../provider/rn_items_provider.dart';

class HorizontalDragWidget extends StatefulWidget {
  const HorizontalDragWidget({Key? key}) : super(key: key);
  static const routeName = "/horizontalDragWidget";

  @override
  State createState() => _HorizontalDragWidget();
}

class InnerList {
  SingleRNItemModel box;
  List<SingleRNItemModel> children;
  InnerList({required this.box, required this.children});
}

class _HorizontalDragWidget extends State<HorizontalDragWidget> {
  late List<InnerList> _lists;

 /* @override
  void initState() {
    super.initState();

  }*/

  @override
  Widget build(BuildContext context) {
    RNItemsProvider rnItemsProvider = Provider.of<RNItemsProvider>(context, listen: true);
    List<SingleRNItemModel> all_items = rnItemsProvider.rnItems;
    List<SingleRNItemModel> boxes = [SingleRNItemModel(id: "1", name: "Unsorted"),];
    boxes.addAll(rnItemsProvider.rnBoxes);
    print("Anzahl der Boxen:${boxes.length}");
    print("Anzahl der Items:${all_items.length}");


    _lists = List.generate(boxes.length, (outerIndex) {
      if(outerIndex == 0) {
        return InnerList(
          box: boxes[outerIndex],
          children: [],
        );
      }
      return InnerList(
        box: boxes[outerIndex],
        children: List.generate(boxes[outerIndex].contains.length, (innerIndex) => all_items.firstWhere((element) => element.id == boxes[outerIndex].contains[innerIndex])),
      );
    });

    List<SingleRNItemModel> remainingItems = List.from(all_items);
    for(int i = 0; i < _lists.length; i++) {
      for(int j = 0; j < _lists[i].children.length; j++) {
        remainingItems.remove(_lists[i].children[j]);
      }
    }
    _lists[0].children = remainingItems;


    return SizedBox(
      height: MediaQuery.of(context).size.height-14,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Warehouse'),
        ),
        drawer: NavigationDrawer(children: [],),
        body: DragAndDropLists(
          children: List.generate(_lists.length, (index) => _buildList(index)),
          onItemReorder: _onItemReorder,
          onListReorder: _onListReorder,
          axis: Axis.horizontal,
          listWidth: 300,
          listDraggingWidth: 150,
          listDecoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.all(Radius.circular(7.0)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.black45,
                spreadRadius: 3.0,
                blurRadius: 6.0,
                offset: Offset(2, 3),
              ),
            ],
          ),
          listPadding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropList(
      header: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
                color: Colors.grey,
              ),
              padding: const EdgeInsets.all(10),
              child: SingleRNBoxWidget(
                id: _lists[outerIndex].box.id,
                position: outerIndex,
              ),
            ),
          ),
        ],
      ),
      footer: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(7.0)),
                color: Colors.grey,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                  children: [
                    outerIndex == 0 ?
                    ElevatedButton(onPressed: (){
                      Provider.of<RNItemsProvider>(context, listen: false).addNewRNItem(context);
                    }, child: const Text("Add item")) : Container(),
                  ]
              ),
            ),
          ),
        ],
      ),
      leftSide: const VerticalDivider(
        color: Colors.grey,
        width: 1.5,
        thickness: 1.5,
      ),
      rightSide: const VerticalDivider(
        color: Colors.grey,
        width: 1.5,
        thickness: 1.5,
      ),
      children: List.generate(innerList.children.length,
              (index) => _buildItem(SingleRNItemWidget(id:innerList.children[index].id),
    )));
  }

  _buildItem(Widget item) {
    return DragAndDropItem(
      child: ListTile(
        title: item,
      ),
    );
  }


  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
    print("Item ${_lists[newListIndex].children[newItemIndex].id} moved from ${_lists[oldListIndex].box.id} to ${_lists[newListIndex].box.id}");
    // Hier den Provider aktualisieren
    Provider.of<RNItemsProvider>(context, listen: false).updateItemPosition(
      id: _lists[newListIndex].children[newItemIndex].id,
      oldBoxId: _lists[oldListIndex].box.id,
      newBoxId: _lists[newListIndex].box.id,
    );
  }


  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}