import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/widget/single_rn_box_widget.dart';
import 'package:rescuenet_warehouse/widget/single_rn_item_widget.dart';

import '../model/single_rn_item_model.dart';
import '../provider/rn_items_provider.dart';

class HorizontalDragWidget extends StatefulWidget {
  final List<InnerList> lists;
  const HorizontalDragWidget({Key? key, required this.lists}) : super(key: key);
  static const routeName = "/horizontalDragWidget";

  @override
  State createState() => _HorizontalDragWidget();
}

class InnerList {
  SingleRNItemModel box;
  List<SingleRNItemModel> children;
  double weight = 0;

  InnerList({required this.box, required this.children, required this.weight});
}

class _HorizontalDragWidget extends State<HorizontalDragWidget> {

  /* @override
  void initState() {
    super.initState();

  }*/

  @override
  Widget build(BuildContext context) {

    return DragAndDropLists(
          children: List.generate(widget.lists.length, (index) => _buildList(index)),
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

    );
  }

  _buildList(int outerIndex) {
    var innerList = widget.lists[outerIndex];
    return DragAndDropList(
        header: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(7.0)),
                  color: Colors.grey,
                ),
                padding: const EdgeInsets.all(10),
                child: SingleRNBoxWidget(
                  id: widget.lists[outerIndex].box.id,
                  position: outerIndex,
                  wight: widget.lists[outerIndex].weight,
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
                child: Column(children: [
                  outerIndex == 0
                      ? ElevatedButton(
                          onPressed: () {
                            Provider.of<RNItemsProvider>(context, listen: false)
                                .addNewRNItem(context);
                          },
                          child: const Text("Add item"))
                      : Container(),
                ]),
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
        children: List.generate(
            innerList.children.length,
            (index) => _buildItem(
                  SingleRNItemWidget(id: innerList.children[index].id),
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
      var movedItem = widget.lists[oldListIndex].children.removeAt(oldItemIndex);
      widget.lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
    print(
        "Item ${widget.lists[newListIndex].children[newItemIndex].id} moved from ${widget.lists[oldListIndex].box.id} to ${widget.lists[newListIndex].box.id}");
    // Hier den Provider aktualisieren
    Provider.of<RNItemsProvider>(context, listen: false).updateItemPosition(
      id: widget.lists[newListIndex].children[newItemIndex].id,
      oldBoxId: widget.lists[oldListIndex].box.id,
      newBoxId: widget.lists[newListIndex].box.id,
    );
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = widget.lists.removeAt(oldListIndex);
      widget.lists.insert(newListIndex, movedList);
    });
  }
}
