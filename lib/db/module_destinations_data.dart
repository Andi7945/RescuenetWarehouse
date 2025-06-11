import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/module_destination.dart';

part 'module_destinations_data.g.dart';

@riverpod
class ModuleDestinationsData extends _$ModuleDestinationsData {
  @override
  List<ModuleDestination> build() {
    _initFirebase();
    return [];
  }

  _initFirebase() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    moduleDestinationsCollection.snapshots().listen((entries) {
      state = entries.docs.map((e) => e.data()).toList();
      print("Loaded module destinations: ${state.length}");
    }, onError: (error) => print("Listen failed: $error"));
  }

  Future<void> upsert(ModuleDestination destination) =>
      _upsertFirebase(destination);

  Future<void> _upsertFirebase(ModuleDestination destination) =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return moduleDestinationsCollection
            .doc(destination.id)
            .set(destination);
      });

  delete(ModuleDestination? destination) async => _deleteFirebase(destination);

  _deleteFirebase(ModuleDestination? destination) async =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return moduleDestinationsCollection.doc(destination?.id).delete();
      });
}
