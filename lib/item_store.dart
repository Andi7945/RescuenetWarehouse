import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/main.dart';

import 'item.dart';

class ItemStore extends ChangeNotifier {
  final _collection = FirebaseFirestore.instance
      .collection("items")
      .withConverter(
          fromFirestore: Item.fromFirestore,
          toFirestore: (Item item, _) => item.toFirestore());
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
      _itemListener = _collection.snapshots().listen(
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

  updateItem(Item item) async {
    await _collection.doc(item.id).set(item);
  }

  newItem() {
    var newRescueNetId = _items.map((e) => e.rescueNetId).reduce(max) + 1;
    var item = Item(uuid.v4(), 0, newRescueNetId);
    updateItem(item);
    return item;
  }
}
