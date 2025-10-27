import 'package:rescuenet_warehouse/models/container_type.dart';

/// Repository interface for managing container types.
///
/// Container types define the physical specifications and properties of containers
/// including weight, measurements, and visual identification.
abstract class ContainerTypeRepository {
  /// Stream of all container types with real-time updates
  Stream<List<ContainerType>> watchContainerTypes();

  /// Get a specific container type by its ID
  Future<ContainerType?> getContainerType(String id);

  /// Get all container types as a list
  Future<List<ContainerType>> getAllContainerTypes();

  /// Create or update a container type
  Future<void> upsertContainerType(ContainerType containerType);

  /// Create a new container type
  /// Alias for upsertContainerType for compatibility
  Future<void> createContainerType(ContainerType containerType);

  /// Update an existing container type
  /// Alias for upsertContainerType for compatibility
  Future<void> updateContainerType(ContainerType containerType);

  /// Delete a container type by ID
  Future<void> deleteContainerType(String id);
}
