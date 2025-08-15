// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_locations_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentLocationsNotifierHash() =>
    r'116bc8f781f550a16433558544d18f5af3251979';

/// See also [CurrentLocationsNotifier].
@ProviderFor(CurrentLocationsNotifier)
final currentLocationsNotifierProvider = AutoDisposeNotifierProvider<
  CurrentLocationsNotifier,
  List<CurrentLocation>
>.internal(
  CurrentLocationsNotifier.new,
  name: r'currentLocationsNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentLocationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentLocationsNotifier = AutoDisposeNotifier<List<CurrentLocation>>;
String _$currentLocationsAsyncHash() =>
    r'5b19da386117d7708492372a645f4f013fa84e93';

/// See also [CurrentLocationsAsync].
@ProviderFor(CurrentLocationsAsync)
final currentLocationsAsyncProvider = AutoDisposeStreamNotifierProvider<
  CurrentLocationsAsync,
  List<CurrentLocation>
>.internal(
  CurrentLocationsAsync.new,
  name: r'currentLocationsAsyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentLocationsAsyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentLocationsAsync =
    AutoDisposeStreamNotifier<List<CurrentLocation>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
