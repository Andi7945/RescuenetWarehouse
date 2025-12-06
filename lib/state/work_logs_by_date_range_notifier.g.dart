// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_logs_by_date_range_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workLogsByDateRangeHash() =>
    r'3c8a210b726369053dea8ce9ebfef060e0a38be3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$WorkLogsByDateRange
    extends BuildlessAutoDisposeStreamNotifier<List<LogEntry>> {
  late final DateTime startDate;
  late final DateTime endDate;

  Stream<List<LogEntry>> build(DateTime startDate, DateTime endDate);
}

/// Watches work logs within a specific date range.
/// Only rebuilds when logs within THIS range change.
///
/// Useful for daily/weekly audit reports.
///
/// Usage:
/// ```dart
/// final todayLogs = ref.watch(workLogsByDateRangeProvider(
///   DateTime.now(),
///   DateTime.now().add(Duration(days: 1)),
/// ));
/// ```
///
/// Copied from [WorkLogsByDateRange].
@ProviderFor(WorkLogsByDateRange)
const workLogsByDateRangeProvider = WorkLogsByDateRangeFamily();

/// Watches work logs within a specific date range.
/// Only rebuilds when logs within THIS range change.
///
/// Useful for daily/weekly audit reports.
///
/// Usage:
/// ```dart
/// final todayLogs = ref.watch(workLogsByDateRangeProvider(
///   DateTime.now(),
///   DateTime.now().add(Duration(days: 1)),
/// ));
/// ```
///
/// Copied from [WorkLogsByDateRange].
class WorkLogsByDateRangeFamily extends Family<AsyncValue<List<LogEntry>>> {
  /// Watches work logs within a specific date range.
  /// Only rebuilds when logs within THIS range change.
  ///
  /// Useful for daily/weekly audit reports.
  ///
  /// Usage:
  /// ```dart
  /// final todayLogs = ref.watch(workLogsByDateRangeProvider(
  ///   DateTime.now(),
  ///   DateTime.now().add(Duration(days: 1)),
  /// ));
  /// ```
  ///
  /// Copied from [WorkLogsByDateRange].
  const WorkLogsByDateRangeFamily();

  /// Watches work logs within a specific date range.
  /// Only rebuilds when logs within THIS range change.
  ///
  /// Useful for daily/weekly audit reports.
  ///
  /// Usage:
  /// ```dart
  /// final todayLogs = ref.watch(workLogsByDateRangeProvider(
  ///   DateTime.now(),
  ///   DateTime.now().add(Duration(days: 1)),
  /// ));
  /// ```
  ///
  /// Copied from [WorkLogsByDateRange].
  WorkLogsByDateRangeProvider call(DateTime startDate, DateTime endDate) {
    return WorkLogsByDateRangeProvider(startDate, endDate);
  }

  @override
  WorkLogsByDateRangeProvider getProviderOverride(
    covariant WorkLogsByDateRangeProvider provider,
  ) {
    return call(provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workLogsByDateRangeProvider';
}

/// Watches work logs within a specific date range.
/// Only rebuilds when logs within THIS range change.
///
/// Useful for daily/weekly audit reports.
///
/// Usage:
/// ```dart
/// final todayLogs = ref.watch(workLogsByDateRangeProvider(
///   DateTime.now(),
///   DateTime.now().add(Duration(days: 1)),
/// ));
/// ```
///
/// Copied from [WorkLogsByDateRange].
class WorkLogsByDateRangeProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          WorkLogsByDateRange,
          List<LogEntry>
        > {
  /// Watches work logs within a specific date range.
  /// Only rebuilds when logs within THIS range change.
  ///
  /// Useful for daily/weekly audit reports.
  ///
  /// Usage:
  /// ```dart
  /// final todayLogs = ref.watch(workLogsByDateRangeProvider(
  ///   DateTime.now(),
  ///   DateTime.now().add(Duration(days: 1)),
  /// ));
  /// ```
  ///
  /// Copied from [WorkLogsByDateRange].
  WorkLogsByDateRangeProvider(DateTime startDate, DateTime endDate)
    : this._internal(
        () => WorkLogsByDateRange()
          ..startDate = startDate
          ..endDate = endDate,
        from: workLogsByDateRangeProvider,
        name: r'workLogsByDateRangeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workLogsByDateRangeHash,
        dependencies: WorkLogsByDateRangeFamily._dependencies,
        allTransitiveDependencies:
            WorkLogsByDateRangeFamily._allTransitiveDependencies,
        startDate: startDate,
        endDate: endDate,
      );

  WorkLogsByDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;

  @override
  Stream<List<LogEntry>> runNotifierBuild(
    covariant WorkLogsByDateRange notifier,
  ) {
    return notifier.build(startDate, endDate);
  }

  @override
  Override overrideWith(WorkLogsByDateRange Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkLogsByDateRangeProvider._internal(
        () => create()
          ..startDate = startDate
          ..endDate = endDate,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<WorkLogsByDateRange, List<LogEntry>>
  createElement() {
    return _WorkLogsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkLogsByDateRangeProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkLogsByDateRangeRef
    on AutoDisposeStreamNotifierProviderRef<List<LogEntry>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _WorkLogsByDateRangeProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          WorkLogsByDateRange,
          List<LogEntry>
        >
    with WorkLogsByDateRangeRef {
  _WorkLogsByDateRangeProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as WorkLogsByDateRangeProvider).startDate;
  @override
  DateTime get endDate => (origin as WorkLogsByDateRangeProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
