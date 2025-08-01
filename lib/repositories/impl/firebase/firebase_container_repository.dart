import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../container_repository.dart';
import '../../../models/container_dao.dart';
import '../../../db/firebase.dart';

/// Firebase implementation of ContainerRepository.
/// Wraps Firebase Firestore operations with error handling and type conversion.
class FirebaseContainerRepository implements ContainerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<QuerySnapshot<ContainerDao>>? _containersSubscription;
  final StreamController<List<ContainerDao>> _containersController = StreamController<List<ContainerDao>>.broadcast();

  FirebaseContainerRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance {
    _initializeAuthListener();
  }

  /// Initialize authentication state listener to manage Firestore subscriptions
  void _initializeAuthListener() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Handle authentication state changes
  void _onAuthStateChanged(User? user) {
    if (user != null) {
      _startListeningToContainers();
    } else {
      _stopListeningToContainers();
    }
  }

  /// Start listening to containers collection
  void _startListeningToContainers() {
    _containersSubscription?.cancel();
    _containersSubscription = containersCollection.snapshots().listen(
      (snapshot) {
        final containers = snapshot.docs.map((doc) => doc.data()).toList();
        _containersController.add(containers);
      },
      onError: (error) {
        _containersController.addError(_convertException(error));
      },
    );
  }

  /// Stop listening to containers collection
  void _stopListeningToContainers() {
    _containersSubscription?.cancel();
    _containersSubscription = null;
    _containersController.add([]);
  }

  @override
  Stream<List<ContainerDao>> watchContainers() {
    return _containersController.stream;
  }

  @override
  Future<ContainerDao?> getContainer(String id) async {
    try {
      final doc = await containersCollection.doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> upsertContainer(ContainerDao container) async {
    try {
      await containersCollection.doc(container.id).set(container);
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> deleteContainer(String id) async {
    try {
      await containersCollection.doc(id).delete();
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<List<ContainerDao>> getContainersByType(String containerTypeId) async {
    try {
      final snapshot = await containersCollection
          .where('containerTypeId', isEqualTo: containerTypeId)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<List<ContainerDao>> getContainersByLocation(String locationId) async {
    try {
      final snapshot = await containersCollection
          .where('currentLocationId', isEqualTo: locationId)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> batchUpdateContainers(List<ContainerDao> containers) async {
    try {
      await _firestore.runTransaction((transaction) async {
        for (final container in containers) {
          transaction.set(containersCollection.doc(container.id), container);
        }
      });
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> createContainer(ContainerDao container) async {
    return upsertContainer(container);
  }

  @override
  Future<void> updateContainer(ContainerDao container) async {
    return upsertContainer(container);
  }

  /// Converts Firebase and other exceptions to ContainerException.
  ContainerException _convertException(Object exception) {
    if (exception is FirebaseException) {
      return ContainerException(
        exception.message ?? 'Firebase error occurred',
        code: exception.code,
        originalException: exception,
      );
    } else {
      return ContainerException(
        'An unexpected error occurred during container operation',
        originalException: exception,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _containersSubscription?.cancel();
    _containersController.close();
  }
}