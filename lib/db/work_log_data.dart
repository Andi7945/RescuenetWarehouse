import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/log_entry.dart';

part 'work_log_data.g.dart';

@riverpod
class WorkLogData extends _$WorkLogData {
  @override
  List<LogEntry> build() {
    _initFirebase();
    return [];
  }

  _initFirebase() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  _onAuthChange(User? user) {
    if (user == null) return;
    workLogCollection.snapshots().listen((entries) {
      state = entries.docs.map((e) => e.data()).toList();
    }, onError: (error) => print("Listen failed: $error"));
  }

  upsert(LogEntry log) => _upsertFirebase(log);

  _upsertFirebase(LogEntry log) {
    workLogCollection.doc(log.id).set(log);
  }
}
