import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/main.dart';

import 'data_mocks.dart';
import 'item.dart';

class ItemStore extends ChangeNotifier {
  static const String _firebasePath = 'items';
  final List<Item> _items = [
    item_fire,
    item_chair,
    item_desk,
    item_generator,
    item_cooler,
    item_para,
    item_splint
  ];

  // void listenToRNItemsFromFB() {
  //   FirebaseFirestore.instance
  //       .collection(_firebasePath)
  //       .snapshots()
  //       .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
  //     List<SingleRNItemModel> _rnIncome = querySnapshot.docs
  //         .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
  //         SingleRNItemModel.fromJson(e.data(), e.id))
  //         .toList();
  //     _rnItems = _rnIncome.where((element) => element.isBox == false).toList();
  //     _rnBoxes = _rnIncome.where((element) => element.isBox).toList();
  //     print("RNItems from Firebase: ${_rnItems.length}");
  //     print("RNBoxes from Firebase: ${_rnBoxes.length}");
  //     notifyListeners();
  //   });
  // }

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  updateItem(Item item) {
    var idx = _items.indexWhere((element) => element.id == item.id);
    if (idx != -1) {
      _items.replaceRange(idx, idx + 1, [item]);
      notifyListeners();
    }
  }

  newItem() {
    var newRescueNetId = _items.map((e) => e.rescueNetId).reduce(max) + 1;
    var item = Item(uuid.v4(), 0, newRescueNetId);
    _items.add(item);
    return item;
  }
}
