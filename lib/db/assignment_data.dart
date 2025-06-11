import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/assignment.dart';

part 'assignment_data.g.dart';

@riverpod
class AssignmentData extends _$AssignmentData {
  @override
  List<Assignment> build() {
    _initFirebase();
    return [];
  }

  _initFirebase() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    assignmentCollection.snapshots().listen((entries) {
      state = entries.docs.map((e) => e.data()).toList();
    }, onError: (error) => print("Listen failed: $error"));
  }

  upsertOrDelete(Assignment assignment) {
    if (assignment.count == 0) {
      _delete(assignment);
    } else {
      _upsert(assignment);
    }
  }

  _delete(Assignment assignment) {
    state = [...state.where((c) => c.id != assignment.id)];
    assignmentCollection.doc(assignment.id).delete();
  }

  _upsert(Assignment assignment) {
    state = [...state.where((c) => c.id != assignment.id), assignment];
    assignmentCollection.doc(assignment.id).set(assignment);
  }
}
