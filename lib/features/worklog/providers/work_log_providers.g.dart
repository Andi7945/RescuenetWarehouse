// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workLogRepositoryHash() => r'9748a96d65c58b3442c952304ad35109895bba4a';

/// Provider for WorkLogRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
///
/// This is the single source of truth for work log repository dependency injection.
/// All work log notifiers and services should depend on this provider.
///
/// Can switch between Firebase (production) and Mock (testing) implementations
/// using the USE_MOCK_REPOSITORIES environment variable.
///
/// Copied from [workLogRepository].
@ProviderFor(workLogRepository)
final workLogRepositoryProvider =
    AutoDisposeProvider<WorkLogRepository>.internal(
      workLogRepository,
      name: r'workLogRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workLogRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkLogRepositoryRef = AutoDisposeProviderRef<WorkLogRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
