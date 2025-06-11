import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/current_location.dart';

part 'current_locations_data.g.dart';

@riverpod
class CurrentLocationsData extends _$CurrentLocationsData {
  @override
  List<CurrentLocation> build() {
    _initFirebase();
    return [];
  }

  _initFirebase() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    currentLocationsCollection.snapshots().listen((entries) {
      state = entries.docs.map((e) => e.data()).toList();
      print("Loaded current locations: ${state.length}");
    }, onError: (error) => print("Listen failed: $error"));
  }

  Future<void> upsert(CurrentLocation location) => _upsertFirebase(location);

  Future<void> _upsertFirebase(CurrentLocation location) =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return currentLocationsCollection.doc(location.id).set(location);
      });

  delete(CurrentLocation? location) async => _deleteFirebase(location);

  _deleteFirebase(CurrentLocation? location) async =>
      FirebaseFirestore.instance.runTransaction((Transaction transaction) {
        return currentLocationsCollection.doc(location?.id).delete();
      });
}
