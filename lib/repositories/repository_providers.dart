import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'auth_repository.dart';
import 'item_repository.dart';
import 'container_repository.dart';
import 'assignment_repository.dart';
import 'work_log_repository.dart';
import 'container_type_repository.dart';
import 'current_location_repository.dart';
import 'module_destination_repository.dart';
import 'impl/firebase/firebase_auth_repository.dart';
import 'impl/firebase/firebase_item_repository.dart';
import 'impl/firebase/firebase_container_repository.dart';
import 'impl/firebase/firebase_assignment_repository.dart';
import 'impl/firebase/firebase_work_log_repository.dart';
import 'impl/firebase/firebase_container_type_repository.dart';
import 'impl/firebase/firebase_current_location_repository.dart';
import 'impl/firebase/firebase_module_destination_repository.dart';
import 'impl/mock/mock_auth_repository.dart';
import 'impl/mock/mock_item_repository.dart';
import 'impl/mock/mock_container_repository.dart';
import 'impl/mock/mock_assignment_repository.dart';
import 'impl/mock/mock_work_log_repository.dart';
import 'impl/mock/mock_container_type_repository.dart';
import 'impl/mock/mock_current_location_repository.dart';
import 'impl/mock/mock_module_destination_repository.dart';

part 'repository_providers.g.dart';

/// Environment variable to determine which repository implementation to use.
/// Set to 'mock' for testing, 'firebase' for production.
const String _repositoryMode = String.fromEnvironment('REPOSITORY_MODE', defaultValue: 'firebase');

/// Runtime detection of mock mode for Playwright tests.
/// Checks if the web environment has MOCK_FIREBASE_MODE flag set to true.
bool _isRuntimeMockMode() {
  try {
    // Check if we're in a web environment with mock Firebase enabled
    // Only return true if MOCK_FIREBASE_MODE is explicitly set to true
    final mockModeValue = js.context['MOCK_FIREBASE_MODE'];
    final mockMode = mockModeValue == true;
    //print('🔍 _isRuntimeMockMode() - MOCK_FIREBASE_MODE: $mockModeValue, result: $mockMode');

    // Also log to JavaScript console for debugging
    //html.window.console.log('🔍 FLUTTER: _isRuntimeMockMode() - MOCK_FIREBASE_MODE: $mockModeValue, result: $mockMode');

    return mockMode;
  } catch (e) {
    // If we can't access window properties, assume normal Firebase mode
    print('🔍 _isRuntimeMockMode() - ERROR accessing window: $e, defaulting to false');
    html.window.console.log('🔍 FLUTTER: _isRuntimeMockMode() - ERROR accessing window: $e, defaulting to false');
    return false;
  }
}

/// Determine whether to use mock repositories.
/// Returns true if either environment variable is set to 'mock' or runtime mock mode is detected.
bool _shouldUseMockRepositories() {
  final envMockMode = _repositoryMode == 'mock';
  final runtimeMockMode = _isRuntimeMockMode();
  final result = envMockMode || runtimeMockMode;
  //print('🎯 _shouldUseMockRepositories() - env: $_repositoryMode, envMock: $envMockMode, runtimeMock: $runtimeMockMode, RESULT: $result');
  //html.window.console.log('🎯 FLUTTER: _shouldUseMockRepositories() - env: $_repositoryMode, envMock: $envMockMode, runtimeMock: $runtimeMockMode, RESULT: $result');
  return result;
}


/// Provider for AuthRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final useMock = _shouldUseMockRepositories();
  if (useMock) {
    print('🚀 AUTH REPOSITORY: Creating MockAuthRepository');
    html.window.console.log('🚀 FLUTTER: AUTH REPOSITORY Creating MockAuthRepository');
    return MockAuthRepository();
  } else {
    print('🚀 AUTH REPOSITORY: Creating FirebaseAuthRepository');
    html.window.console.log('🚀 FLUTTER: AUTH REPOSITORY Creating FirebaseAuthRepository');
    return FirebaseAuthRepository();
  }
}

/// Provider for ItemRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  if (_shouldUseMockRepositories()) {
    return MockItemRepository();
  } else {
    return FirebaseItemRepository();
  }
}

/// Provider for ContainerRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
ContainerRepository containerRepository(ContainerRepositoryRef ref) {
  if (_shouldUseMockRepositories()) {
    return MockContainerRepository();
  } else {
    return FirebaseContainerRepository();
  }
}

/// Provider for AssignmentRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
AssignmentRepository assignmentRepository(AssignmentRepositoryRef ref) {
  if (_shouldUseMockRepositories()) {
    return MockAssignmentRepository();
  } else {
    return FirebaseAssignmentRepository();
  }
}

/// Provider for WorkLogRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
WorkLogRepository workLogRepository(WorkLogRepositoryRef ref) {
  if (_shouldUseMockRepositories()) {
    return MockWorkLogRepository();
  } else {
    return FirebaseWorkLogRepository();
  }
}

/// Provider for ContainerTypeRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
ContainerTypeRepository containerTypeRepository(ContainerTypeRepositoryRef ref) {
  if (_shouldUseMockRepositories()) {
    return MockContainerTypeRepository();
  } else {
    return FirebaseContainerTypeRepository();
  }
}

/// Provider for CurrentLocationRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
CurrentLocationRepository currentLocationRepository(CurrentLocationRepositoryRef ref) {
  if (_shouldUseMockRepositories()) {
    return MockCurrentLocationRepository();
  } else {
    return FirebaseCurrentLocationRepository();
  }
}

/// Provider for ModuleDestinationRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
@riverpod
ModuleDestinationRepository moduleDestinationRepository(ModuleDestinationRepositoryRef ref) {
  if (_shouldUseMockRepositories()) {
    return MockModuleDestinationRepository();
  } else {
    return FirebaseModuleDestinationRepository();
  }
}

/// Utility provider to check if we're running in mock mode.
/// Useful for conditional behavior in the app.
@riverpod
bool isMockMode(IsMockModeRef ref) {
  return _shouldUseMockRepositories();
}
