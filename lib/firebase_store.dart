import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseStore<T extends FirebaseStorable<T>> extends ChangeNotifier {
  final String collectionName;
  final T Function(Map<String, dynamic> data) buildFn;
  final CollectionReference<T> _collection;

  FirebaseStore(this.collectionName, this.buildFn)
      : _collection = FirebaseFirestore.instance
            .collection(collectionName)
            .withConverter<T>(
                fromFirestore: (snapshot, _) => buildFn(snapshot.data()!),
                toFirestore: (T type, _) => type.toFirestore()) {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  List<T> _list = [];

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

  UnmodifiableListView<T> get containerTypes => UnmodifiableListView(_list);

  T get(String? typeId) => _list.firstWhere((element) => element.id == typeId);

  remove(T? type) async => _collection.doc(type?.id).delete();

  upsert(T type) async => _collection.doc(type.id).set(type);
}

abstract class FirebaseStorable<T> {
  String get id;

  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot);

  Map<String, dynamic> toFirestore();
}
