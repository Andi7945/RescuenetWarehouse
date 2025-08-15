// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignable_items_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignableItemsNotifierHash() =>
    r'4d6eac620bacd35ec3a8e951597d217ae41cfc8f';

/// See also [AssignableItemsNotifier].
@ProviderFor(AssignableItemsNotifier)
final assignableItemsNotifierProvider = AutoDisposeNotifierProvider<
  AssignableItemsNotifier,
  Map<Item, int>
>.internal(
  AssignableItemsNotifier.new,
  name: r'assignableItemsNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignableItemsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AssignableItemsNotifier = AutoDisposeNotifier<Map<Item, int>>;
String _$assignableItemsAsyncHash() =>
    r'4a5301e743d564fbd248245d02cba5e13be2543e';

/// AsyncValue-based assignable items provider for loading states support.
///
/// This provider wraps both items and assignments in AsyncValue to provide proper
/// loading, error, and data states for UI components. It calculates assignable item
/// quantities based on existing assignments while supporting loading states.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<Map<Item, int>>(
///   value: ref.watch(assignableItemsAsyncProvider),
///   data: (assignableItems) => AssignableItemsList(assignableItems: assignableItems),
/// )
/// ```
///
/// Copied from [AssignableItemsAsync].
@ProviderFor(AssignableItemsAsync)
final assignableItemsAsyncProvider = AutoDisposeStreamNotifierProvider<
  AssignableItemsAsync,
  Map<Item, int>
>.internal(
  AssignableItemsAsync.new,
  name: r'assignableItemsAsyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignableItemsAsyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AssignableItemsAsync = AutoDisposeStreamNotifier<Map<Item, int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
