import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../container_type.dart';

class StoreContainerTypes extends ChangeNotifier {
  final _collection = FirebaseFirestore.instance
      .collection("container_type")
      .withConverter(
          fromFirestore: ContainerType.fromFirestore,
          toFirestore: (ContainerType type, _) => type.toFirestore());

  List<ContainerType> _list = [];

  StoreContainerTypes() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    _collection.snapshots().listen(
      (containerTypes) {
        _list = containerTypes.docs.map((e) => e.data()).toList();
        notifyListeners();
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  UnmodifiableListView<ContainerType> get containerTypes =>
      UnmodifiableListView(_list);

  ContainerType get(String? typeId) =>
      _list.firstWhere((element) => element.id == typeId);

  remove(ContainerType? type) async => _collection.doc(type?.id).delete();

  upsert(ContainerType type) async => _collection.doc(type.id).set(type);
}
