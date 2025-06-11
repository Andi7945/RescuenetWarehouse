import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/container_dao.dart';

part 'container_data.g.dart';

@riverpod
class ContainerData extends _$ContainerData {
  @override
  List<ContainerDao> build() {
    _initFirebase();
    return [];
  }

  _initFirebase() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    containersCollection.snapshots().listen((entries) {
      state = entries.docs.map((e) => e.data()).toList();
    }, onError: (error) => print("Listen failed: $error"));
  }

  upsert(ContainerDao container) {
    _upsertFirebase(container);
  }

  _upsertFirebase(ContainerDao container) {
    state = [...state.where((c) => c.id != container.id), container];
    containersCollection.doc(container.id).set(container);
  }

  delete(String id) {
    _deleteFirebase(id);
  }

  void _deleteFirebase(String id) {
    containersCollection.doc(id).delete();
    state = [...state.where((c) => c.id != id)];
  }
}
