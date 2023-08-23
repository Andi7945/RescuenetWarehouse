import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/main.dart';

import 'data_mocks.dart';
import 'item.dart';

class ItemStore extends ChangeNotifier {
  static const String _firebasePath = 'items';
  List<Item> _items = [];

  var _authChangeListener;
  var _itemListener;

  ItemStore() {
    _authChangeListener =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) {
      _itemListener = null;
      print('User is currently signed out!');
    } else {
      _itemListener = FirebaseFirestore.instance
          .collection("items")
          .withConverter(
            fromFirestore: Item.fromFirestore,
            toFirestore: (Item item, _) => item.toFirestore(),
          )
          .snapshots()
          .listen(
        (items) {
          _items = items.docs.map((e) => e.data()).toList();
          notifyListeners();
          print("current data: ${_items.map((e) => e.toJson()).join(",")}");
        },
        onError: (error) => print("Listen failed: $error"),
      );
      print('User is signed in!');
    }
  }

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
