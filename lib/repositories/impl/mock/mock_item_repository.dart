import 'dart:async';
import '../../item_repository.dart';
import '../../../models/item.dart';
import '../../../models/operational_status.dart';

/// Mock implementation of ItemRepository for testing.
/// Simulates item storage behavior without Firebase dependencies.
class MockItemRepository implements ItemRepository {
  final Map<String, Item> _items = {};
  final StreamController<List<Item>> _itemsController = StreamController<List<Item>>.broadcast();

  MockItemRepository() {
    _initializeWithTestData();
  }

  /// Initialize with realistic test data
  void _initializeWithTestData() {
    final testItems = [
      Item(
        id: 'test-item-1',
        name: 'Emergency Medical Kit',
        rescueNetId: 1001,
        totalAmount: 5,
        weight: 2.5,
        description: 'Complete medical kit for emergency situations',
        operationalStatus: OperationalStatus.deployable,
      ),
      Item(
        id: 'test-item-2',
        name: 'Water Purification Tablets',
        rescueNetId: 1002,
        totalAmount: 100,
        weight: 0.1,
        description: 'Water purification tablets for emergency water treatment',
        operationalStatus: OperationalStatus.deployable,
      ),
      Item(
        id: 'test-item-3',
        name: 'Damaged Radio',
        rescueNetId: 1003,
        totalAmount: 1,
        weight: 1.2,
        description: 'Radio equipment - needs repair',
        operationalStatus: OperationalStatus.damaged,
      ),
    ];

    for (final item in testItems) {
      _items[item.id] = item;
    }
    _emitItems();
  }

  @override
  Stream<List<Item>> watchItems() {
    return _itemsController.stream;
  }

  @override
  Future<Item?> getItem(String id) async {
    await _simulateNetworkDelay();
    return _items[id];
  }

  @override
  Future<void> upsertItem(Item item) async {
    await _simulateNetworkDelay();
    _items[item.id] = item;
    _emitItems();
  }

  @override
  Future<void> deleteItem(String id) async {
    await _simulateNetworkDelay();
    
    if (!_items.containsKey(id)) {
      throw const ItemException('Item not found', code: 'not-found');
    }
    
    _items.remove(id);
    _emitItems();
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    await _simulateNetworkDelay();
    
    if (query.isEmpty) return _items.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _items.values.where((item) {
      return (item.name?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (item.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<Item>> getItemsByStatus(String operationalStatus) async {
    await _simulateNetworkDelay();
    
    return _items.values.where((item) {
      return item.operationalStatus.toString() == operationalStatus;
    }).toList();
  }

  @override
  Future<void> batchUpdateItems(List<Item> items) async {
    await _simulateNetworkDelay();
    
    for (final item in items) {
      _items[item.id] = item;
    }
    _emitItems();
  }

  /// Emit current items list to stream
  void _emitItems() {
    _itemsController.add(_items.values.toList());
  }

  /// Simulate network delay for realistic testing
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Add test items for specific test scenarios
  void addTestItem(Item item) {
    _items[item.id] = item;
    _emitItems();
  }

  /// Clear all items (useful for test cleanup)
  void clearItems() {
    _items.clear();
    _emitItems();
  }

  /// Get current item count
  int get itemCount => _items.length;

  /// Check if item exists by ID
  bool hasItem(String id) => _items.containsKey(id);

  /// Dispose resources
  void dispose() {
    _itemsController.close();
  }
}