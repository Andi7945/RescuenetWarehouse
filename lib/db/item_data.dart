import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/item.dart';

part 'item_data.g.dart';

@riverpod
class ItemData extends _$ItemData {
  @override
  List<Item> build() {
    _initFirebase();
    return [];
  }

  _initFirebase() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    itemsCollection.snapshots().listen((entries) {
      state = entries.docs.map((e) => e.data()).toList();
    }, onError: (error) => print("Listen failed: $error"));
  }

  Future<void> upsert(Item item) => _upsertFirebase(item);

  Future<void> _upsertFirebase(Item item) =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return itemsCollection.doc(item.id).set(item);
      });

  Future<void> delete(String id) => _deleteFirebase(id);

  Future<void> _deleteFirebase(String id) =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return itemsCollection.doc(id).delete();
      });
}
