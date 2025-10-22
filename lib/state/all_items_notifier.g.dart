// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_items_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allItemsStreamHash() => r'eb2b6ac5724fc707bf62cc33808cba986f36b3a3';

/// Stream-based provider for backward compatibility.
/// This maintains the existing Stream<List<Item>> pattern that other
/// parts of the app may depend on.
///
/// Copied from [allItemsStream].
@ProviderFor(allItemsStream)
final allItemsStreamProvider = AutoDisposeStreamProvider<List<Item>>.internal(
  allItemsStream,
  name: r'allItemsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allItemsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllItemsStreamRef = AutoDisposeStreamProviderRef<List<Item>>;
String _$allItemsNotifierHash() => r'c4dd5f5432bc49914ef4d4f4672f3ed403bf27b9';

/// See also [AllItemsNotifier].
@ProviderFor(AllItemsNotifier)
final allItemsNotifierProvider =
    AutoDisposeNotifierProvider<AllItemsNotifier, List<Item>>.internal(
      AllItemsNotifier.new,
      name: r'allItemsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allItemsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllItemsNotifier = AutoDisposeNotifier<List<Item>>;
String _$allItemsAsyncHash() => r'068d9143734123187a03ef23ed52c7370a9dfb9e';

/// AsyncValue-based items provider for loading states support.
///
/// This provider wraps the items stream in AsyncValue to provide proper
/// loading, error, and data states for UI components. It follows the enhanced
/// pattern from LOADING_INDICATORS_DESIGN.md while maintaining compatibility
/// with the existing AllItemsNotifier.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<Item>>(
///   value: ref.watch(allItemsAsyncProvider),
///   data: (items) => ItemGrid(items: items),
/// )
/// ```
///
/// Copied from [AllItemsAsync].
@ProviderFor(AllItemsAsync)
final allItemsAsyncProvider =
    AutoDisposeStreamNotifierProvider<AllItemsAsync, List<Item>>.internal(
      AllItemsAsync.new,
      name: r'allItemsAsyncProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allItemsAsyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllItemsAsync = AutoDisposeStreamNotifier<List<Item>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
