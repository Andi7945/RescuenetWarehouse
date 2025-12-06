import 'dart:async';
import '../models/item.dart';
import '../models/operational_status.dart';

/// Abstract interface for item operations.
/// Provides a clean abstraction over Firebase Firestore with testable interfaces.
abstract class ItemRepository {
  /// Stream of all items.
  /// Emits updated list whenever items change in the database.
  Stream<List<Item>> watchItems();

  /// Get a single item by ID.
  /// Returns null if item doesn't exist.
  Future<Item?> getItem(String id);

  /// Create or update an item.
  /// Uses the item's ID for the document reference.
  Future<void> upsertItem(Item item);

  /// Delete an item by ID.
  /// Throws ItemException if item doesn't exist or deletion fails.
  Future<void> deleteItem(String id);

  /// Search items by name, description, or other searchable fields.
  /// Returns empty list if no matches found.
  Future<List<Item>> searchItems(String query);

  /// Get items filtered by operational status.
  Future<List<Item>> getItemsByStatus(String operationalStatus);

  /// Batch update multiple items in a single transaction.
  /// All operations succeed or all fail together.
  Future<void> batchUpdateItems(List<Item> items);

  // NEW: Fine-grained stream methods

  /// Watch a single item by ID.
  /// Emits only when this specific item changes.
  /// Returns null if item doesn't exist.
  Stream<Item?> watchItem(String itemId);

  /// Watch items with a specific operational status.
  /// Emits only when items with this status change.
  Stream<List<Item>> watchItemsByStatus(OperationalStatus status);

  /// Watch a subset of items by their IDs.
  /// Emits only when items in this subset change.
  /// Returns empty list if no items match.
  Stream<List<Item>> watchItemsByIds(List<String> itemIds);
}

/// Exception thrown by ItemRepository implementations.
class ItemException implements Exception {
  final String message;
  final String? code;
  final Object? originalException;

  const ItemException(this.message, {this.code, this.originalException});

  @override
  String toString() =>
      'ItemException: $message${code != null ? ' (code: $code)' : ''}';
}
