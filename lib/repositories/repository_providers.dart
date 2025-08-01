import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_repository.dart';
import 'item_repository.dart';
import 'container_repository.dart';
import 'impl/firebase/firebase_auth_repository.dart';
import 'impl/firebase/firebase_item_repository.dart';
import 'impl/firebase/firebase_container_repository.dart';
import 'impl/mock/mock_auth_repository.dart';
import 'impl/mock/mock_item_repository.dart';
import 'impl/mock/mock_container_repository.dart';

part 'repository_providers.g.dart';

/// Environment variable to determine which repository implementation to use.
/// Set to 'mock' for testing, 'firebase' for production.
const String _repositoryMode = String.fromEnvironment('REPOSITORY_MODE', defaultValue: 'firebase');

/// Provider for AuthRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  switch (_repositoryMode) {
    case 'mock':
      return MockAuthRepository();
    case 'firebase':
    default:
      return FirebaseAuthRepository();
  }
}

/// Provider for ItemRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  switch (_repositoryMode) {
    case 'mock':
      return MockItemRepository();
    case 'firebase':
    default:
      return FirebaseItemRepository();
  }
}

/// Provider for ContainerRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
ContainerRepository containerRepository(ContainerRepositoryRef ref) {
  switch (_repositoryMode) {
    case 'mock':
      return MockContainerRepository();
    case 'firebase':
    default:
      return FirebaseContainerRepository();
  }
}

/// Utility provider to check if we're running in mock mode.
/// Useful for conditional behavior in the app.
@riverpod
bool isMockMode(IsMockModeRef ref) {
  return _repositoryMode == 'mock';
}