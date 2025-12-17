/// Work Log Feature - Public API
///
/// This barrel file provides the complete public API for the work log feature,
/// which manages the audit trail of all item-container assignment changes.
///
/// ## Repository Layer
/// - [WorkLogRepository]: Abstract interface for work log data access
///
/// ## Providers
/// - [workLogRepositoryProvider]: Dependency injection for WorkLogRepository
///   (switches between Firebase and Mock implementations)
///
/// ## Business Logic - State Notifiers
/// - [AllWorkLogsNotifier]: Manages all work log entries with real-time updates
/// - [WorkLogNotifier]: Manages a single work log entry by ID
/// - [WorkLogSinceNotifier]: Manages work logs since a specific date
/// - [WorkLogsByDateRangeNotifier]: Manages work logs within a date range (fine-grained)
/// - [WorkLogsByUserNotifier]: Manages work logs for a specific user (fine-grained)
/// - [WorkLogsByItemNotifier]: Manages work logs for a specific item (fine-grained)
/// - [WorkLogsByContainerNotifier]: Manages work logs for a specific container (fine-grained)
/// - [WorkLogDateFilterNotifier]: Manages date filter state for work log UI
///
/// ## Business Logic - Aggregation Functions
/// - [sumDailyChanges]: Aggregates daily log entries by item and container,
///   summing counts and tracking users (pure function)
///
/// ## Usage Examples
///
/// ### Watch all work logs
/// ```dart
/// final workLogs = ref.watch(allWorkLogsProvider);
/// ```
///
/// ### Watch work logs for specific container (fine-grained)
/// ```dart
/// final containerLogs = ref.watch(workLogsByContainerProvider('container-123'));
/// ```
///
/// ### Watch work logs for date range (fine-grained)
/// ```dart
/// final todayLogs = ref.watch(workLogsByDateRangeProvider(startDate, endDate));
/// ```
///
/// ### Aggregate daily changes
/// ```dart
/// final summary = sumDailyChanges(logEntries);
/// ```
library;

// Repository Interface
export 'package:rescuenet_warehouse/features/worklog/repository/work_log_repository.dart';

// Providers
export 'package:rescuenet_warehouse/features/worklog/providers/work_log_providers.dart';

// Business Logic - State Notifiers
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/all_work_logs_notifier.dart';
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_log_notifier.dart';
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_log_since_notifier.dart';
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_logs_by_date_range_notifier.dart';
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_logs_by_user_notifier.dart';
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_logs_by_item_notifier.dart';
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_logs_by_container_notifier.dart';
export 'package:rescuenet_warehouse/features/worklog/business_logic/notifiers/work_log_date_filter_notifier.dart';

// Business Logic - Aggregation Functions
export 'package:rescuenet_warehouse/features/worklog/business_logic/aggregation.dart';
