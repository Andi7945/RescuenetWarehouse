// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_work_logs_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allWorkLogsNotifierHash() =>
    r'ad321980d2d7c95546557521fe109eba47a31298';

/// See also [AllWorkLogsNotifier].
@ProviderFor(AllWorkLogsNotifier)
final allWorkLogsNotifierProvider =
    AutoDisposeNotifierProvider<AllWorkLogsNotifier, List<LogEntry>>.internal(
      AllWorkLogsNotifier.new,
      name: r'allWorkLogsNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$allWorkLogsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllWorkLogsNotifier = AutoDisposeNotifier<List<LogEntry>>;
String _$allWorkLogsAsyncHash() => r'9ffb7f1ee1e6d47315b2121f66b164831aa44663';

/// See also [AllWorkLogsAsync].
@ProviderFor(AllWorkLogsAsync)
final allWorkLogsAsyncProvider = AutoDisposeStreamNotifierProvider<
  AllWorkLogsAsync,
  List<LogEntry>
>.internal(
  AllWorkLogsAsync.new,
  name: r'allWorkLogsAsyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allWorkLogsAsyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllWorkLogsAsync = AutoDisposeStreamNotifier<List<LogEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
