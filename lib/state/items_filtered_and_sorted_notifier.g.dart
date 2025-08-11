// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_filtered_and_sorted_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemsFilteredAndSortedCompatHash() =>
    r'60c3687a25b52db692bce3b5ca1d4b1d0a02010f';

/// Backward compatibility provider that returns the same as the original
///
/// Copied from [itemsFilteredAndSortedCompat].
@ProviderFor(itemsFilteredAndSortedCompat)
final itemsFilteredAndSortedCompatProvider =
    AutoDisposeProvider<List<Item>>.internal(
      itemsFilteredAndSortedCompat,
      name: r'itemsFilteredAndSortedCompatProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$itemsFilteredAndSortedCompatHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItemsFilteredAndSortedCompatRef = AutoDisposeProviderRef<List<Item>>;
String _$itemsFilteredAndSortedNotifierHash() =>
    r'0ba39c73c80cf9a854dea5bdbf0bfd5b38f6e9b0';

/// See also [ItemsFilteredAndSortedNotifier].
@ProviderFor(ItemsFilteredAndSortedNotifier)
final itemsFilteredAndSortedNotifierProvider = AutoDisposeNotifierProvider<
  ItemsFilteredAndSortedNotifier,
  List<Item>
>.internal(
  ItemsFilteredAndSortedNotifier.new,
  name: r'itemsFilteredAndSortedNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$itemsFilteredAndSortedNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ItemsFilteredAndSortedNotifier = AutoDisposeNotifier<List<Item>>;
String _$itemsFilteredAndSortedAsyncHash() =>
    r'359bc7c713767972abc55c02000ada61b5fc3e7a';

/// AsyncValue-based filtered and sorted items provider for loading states support.
///
/// This provider combines AsyncValue items data with filtering and sorting,
/// providing proper loading, error, and data states while applying the same
/// filtering and sorting logic as the original provider.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<Item>>(
///   value: ref.watch(itemsFilteredAndSortedAsyncProvider),
///   data: (items) => ItemGrid(items: items),
/// )
/// ```
///
/// Copied from [ItemsFilteredAndSortedAsync].
@ProviderFor(ItemsFilteredAndSortedAsync)
final itemsFilteredAndSortedAsyncProvider = AutoDisposeNotifierProvider<
  ItemsFilteredAndSortedAsync,
  AsyncValue<List<Item>>
>.internal(
  ItemsFilteredAndSortedAsync.new,
  name: r'itemsFilteredAndSortedAsyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$itemsFilteredAndSortedAsyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ItemsFilteredAndSortedAsync =
    AutoDisposeNotifier<AsyncValue<List<Item>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
