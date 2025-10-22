// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_assignments_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allAssignmentsStreamHash() =>
    r'1753ae0e6db0c0b81119994a1a9919693d43fb49';

/// Stream-based provider for backward compatibility.
/// This maintains the existing Stream<List<Assignment>> pattern that other
/// parts of the app may depend on.
///
/// Copied from [allAssignmentsStream].
@ProviderFor(allAssignmentsStream)
final allAssignmentsStreamProvider =
    AutoDisposeStreamProvider<List<Assignment>>.internal(
      allAssignmentsStream,
      name: r'allAssignmentsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allAssignmentsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllAssignmentsStreamRef =
    AutoDisposeStreamProviderRef<List<Assignment>>;
String _$allAssignmentsAsyncHash() =>
    r'66a170e0c5d73a9e5c944f6a9f1a33042f885a4d';

/// AsyncValue-based assignments provider for loading states support.
///
/// This provider wraps the assignments stream in AsyncValue to provide proper
/// loading, error, and data states for UI components. It follows the enhanced
/// pattern from LOADING_INDICATORS_DESIGN.md while maintaining compatibility
/// with the existing AllAssignmentsNotifier.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<Assignment>>(
///   value: ref.watch(allAssignmentsAsyncProvider),
///   data: (assignments) => AssignmentsList(assignments: assignments),
/// )
/// ```
///
/// Copied from [AllAssignmentsAsync].
@ProviderFor(AllAssignmentsAsync)
final allAssignmentsAsyncProvider =
    AutoDisposeStreamNotifierProvider<
      AllAssignmentsAsync,
      List<Assignment>
    >.internal(
      AllAssignmentsAsync.new,
      name: r'allAssignmentsAsyncProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allAssignmentsAsyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllAssignmentsAsync = AutoDisposeStreamNotifier<List<Assignment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
