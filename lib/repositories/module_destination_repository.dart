import 'package:rescue_net_warehouse/models/module_destination.dart';

/// Repository interface for managing module destinations.
/// 
/// Module destinations represent target locations where equipment modules
/// will be deployed or sent for operations.
abstract class ModuleDestinationRepository {
  /// Stream of all module destinations with real-time updates
  Stream<List<ModuleDestination>> watchModuleDestinations();

  /// Get a specific module destination by its ID
  Future<ModuleDestination?> getModuleDestination(String id);

  /// Get all module destinations as a list
  Future<List<ModuleDestination>> getAllModuleDestinations();

  /// Create or update a module destination
  Future<void> upsertModuleDestination(ModuleDestination moduleDestination);

  /// Delete a module destination by ID
  Future<void> deleteModuleDestination(String id);
}