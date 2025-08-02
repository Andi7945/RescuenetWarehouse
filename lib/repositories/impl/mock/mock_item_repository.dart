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

  /// Initialize with realistic test data matching Playwright test expectations
  /// This data matches the fixture format from test/fixtures/items/basic_navigation_items.json
  void _initializeWithTestData() {
    final testItems = [
      Item(
        id: 'item_001',
        name: 'First Aid Kit',
        rescueNetId: 1001,
        totalAmount: 50,
        weight: 2.5,
        description: 'Standard medical supplies',
        operationalStatus: OperationalStatus.deployable,
      ),
      Item(
        id: 'item_002',
        name: 'Water Purification Tablets',
        rescueNetId: 1002,
        totalAmount: 200,
        weight: 0.1,
        description: 'Chemical water treatment',
        operationalStatus: OperationalStatus.deployable,
      ),
      Item(
        id: 'item_003',
        name: 'Emergency Blankets',
        rescueNetId: 1003,
        totalAmount: 100,
        weight: 0.3,
        description: 'Thermal survival blankets',
        operationalStatus: OperationalStatus.deployable,
      ),
    ];

    for (final item in testItems) {
      _items[item.id] = item;
    }
    _emitItems();
  }

  @override
  Stream<List<Item>> watchItems() {
    // Create a new controller that emits current data immediately
    final controller = StreamController<List<Item>>.broadcast();

    // Emit current data immediately using Future.microtask to ensure proper ordering
    Future.microtask(() {
      if (!controller.isClosed) {
        controller.add(_items.values.toList());
      }
    });

    // Forward future updates
    final subscription = _itemsController.stream.listen(
      (items) {
        if (!controller.isClosed) {
          controller.add(items);
        }
      },
    );

    // Handle cleanup
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    return controller.stream;
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
