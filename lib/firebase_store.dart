import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseStore<T extends FirebaseStorable<T>> extends ChangeNotifier {
  bool loaded = false;
  final String collectionName;
  final T Function(Map<String, dynamic> data) buildFn;
  final CollectionReference<T> _collection;

  FirebaseStore(this.collectionName, this.buildFn)
      : _collection = FirebaseFirestore.instance
            .collection(collectionName)
            .withConverter<T>(
                fromFirestore: (snapshot, _) => buildFn(snapshot.data()!),
                toFirestore: (T type, _) => type.toJson()) {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  List<T> _list = [];

  _onAuthChange(User? user) {
    if (user == null) return;
    _collection.snapshots().listen(
      (entries) {
        _list = entries.docs.map((e) => e.data()).toList();
        loaded = true;
        notifyListeners();
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  UnmodifiableListView<T> get all => UnmodifiableListView(_list);

  T get(String? id) => _list.firstWhere((element) => element.id == id);

  remove(T? entity) async => _collection.doc(entity?.id).delete();

  upsert(T entity) async => _collection.doc(entity.id).set(entity);
}

abstract class FirebaseStorable<T> {
  String get id;

  Map<String, dynamic> toJson();
}
