import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/container_type.dart';

part 'container_types_data.g.dart';

@riverpod
class ContainerTypesData extends _$ContainerTypesData {
  @override
  List<ContainerType> build() {
    _initFirebase();
    return [];
  }

  _initFirebase() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    containerTypesCollection.snapshots().listen((entries) {
      state = entries.docs.map((e) => e.data()).toList();
      print("Loaded container types: ${state.length}");
    }, onError: (error) => print("Listen failed: $error"));
  }

  Future<void> upsert(ContainerType type) => _upsertFirebase(type);

  Future<void> _upsertFirebase(ContainerType type) =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return containerTypesCollection.doc(type.id).set(type);
      });

  delete(ContainerType? type) async => _deleteFirebase(type);

  _deleteFirebase(ContainerType? type) async =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return containerTypesCollection.doc(type?.id).delete();
      });
}
