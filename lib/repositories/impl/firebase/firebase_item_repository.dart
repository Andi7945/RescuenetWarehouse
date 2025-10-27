import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../item_repository.dart';
import '../../../models/item.dart';
import '../../../db/firebase.dart';

/// Firebase implementation of ItemRepository.
/// Wraps Firebase Firestore operations with error handling and type conversion.
class FirebaseItemRepository implements ItemRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<QuerySnapshot<Item>>? _itemsSubscription;
  final StreamController<List<Item>> _itemsController =
      StreamController<List<Item>>.broadcast();

  FirebaseItemRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
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
      _startListeningToItems();
    } else {
      _stopListeningToItems();
    }
  }

  /// Start listening to items collection
  void _startListeningToItems() {
    _itemsSubscription?.cancel();
    _itemsSubscription = itemsCollection.snapshots().listen(
      (snapshot) {
        final items = snapshot.docs.map((doc) => doc.data()).toList();
        _itemsController.add(items);
      },
      onError: (error) {
        _itemsController.addError(_convertException(error));
      },
    );
  }

  /// Stop listening to items collection
  void _stopListeningToItems() {
    _itemsSubscription?.cancel();
    _itemsSubscription = null;
    _itemsController.add([]);
  }

  @override
  Stream<List<Item>> watchItems() {
    return _itemsController.stream;
  }

  @override
  Future<Item?> getItem(String id) async {
    try {
      final doc = await itemsCollection.doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> upsertItem(Item item) async {
    try {
      await _firestore.runTransaction((transaction) async {
        transaction.set(itemsCollection.doc(item.id), item);
      });
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _firestore.runTransaction((transaction) async {
        transaction.delete(itemsCollection.doc(id));
      });
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    try {
      // Firestore doesn't support full-text search, so we'll do basic name matching
      // In production, you might want to use Algolia or similar for advanced search
      final snapshot = await itemsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<List<Item>> getItemsByStatus(String operationalStatus) async {
    try {
      final snapshot = await itemsCollection
          .where('operationalStatus', isEqualTo: operationalStatus)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> batchUpdateItems(List<Item> items) async {
    try {
      await _firestore.runTransaction((transaction) async {
        for (final item in items) {
          transaction.set(itemsCollection.doc(item.id), item);
        }
      });
    } catch (e) {
      throw _convertException(e);
    }
  }

  /// Converts Firebase and other exceptions to ItemException.
  ItemException _convertException(Object exception) {
    if (exception is FirebaseException) {
      return ItemException(
        exception.message ?? 'Firebase error occurred',
        code: exception.code,
        originalException: exception,
      );
    } else {
      return ItemException(
        'An unexpected error occurred during item operation',
        originalException: exception,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _itemsSubscription?.cancel();
    _itemsController.close();
  }
}
