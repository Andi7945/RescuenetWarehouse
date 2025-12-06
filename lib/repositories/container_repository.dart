import 'dart:async';
import '../models/container_dao.dart';

/// Abstract interface for container operations.
/// Provides a clean abstraction over Firebase Firestore with testable interfaces.
abstract class ContainerRepository {
  /// Stream of all containers.
  /// Emits updated list whenever containers change in the database.
  Stream<List<ContainerDao>> watchContainers();

  /// Get a single container by ID.
  /// Returns null if container doesn't exist.
  Future<ContainerDao?> getContainer(String id);

  /// Create or update a container.
  /// Uses the container's ID for the document reference.
  Future<void> upsertContainer(ContainerDao container);

  /// Create a new container.
  /// Alias for upsertContainer for compatibility.
  Future<void> createContainer(ContainerDao container);

  /// Update an existing container.
  /// Alias for upsertContainer for compatibility.
  Future<void> updateContainer(ContainerDao container);

  /// Delete a container by ID.
  /// Throws ContainerException if container doesn't exist or deletion fails.
  Future<void> deleteContainer(String id);

  /// Get containers by type.
  Future<List<ContainerDao>> getContainersByType(String containerTypeId);

  /// Get containers by current location.
  Future<List<ContainerDao>> getContainersByLocation(String locationId);

  /// Batch update multiple containers in a single transaction.
  /// All operations succeed or all fail together.
  Future<void> batchUpdateContainers(List<ContainerDao> containers);

  // NEW: Fine-grained stream methods

  /// Watch a single container by ID.
  /// Emits only when this specific container changes.
  Stream<ContainerDao?> watchContainer(String containerId);

  /// Watch containers at a specific location.
  /// Emits only when containers at this location change.
  Stream<List<ContainerDao>> watchContainersByLocation(String locationId);

  /// Watch containers of a specific type.
  /// Emits only when containers of this type change.
  Stream<List<ContainerDao>> watchContainersByType(String containerTypeId);

  /// Watch containers by ready status.
  /// Emits only when containers with this status change.
  Stream<List<ContainerDao>> watchContainersByReadyStatus(bool isReady);

  /// Watch containers by deployment status.
  /// Emits only when containers with this status change.
  Stream<List<ContainerDao>> watchContainersByDeployStatus(bool toDeploy);
}

/// Exception thrown by ContainerRepository implementations.
class ContainerException implements Exception {
  final String message;
  final String? code;
  final Object? originalException;

  const ContainerException(this.message, {this.code, this.originalException});

  @override
  String toString() =>
      'ContainerException: $message${code != null ? ' (code: $code)' : ''}';
}
