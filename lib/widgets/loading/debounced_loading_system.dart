import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for debounced loading behavior
class DebouncedLoadingConfig {
  /// Minimum delay before showing loading indicator (in milliseconds)
  final int minimumDelay;
  
  /// Maximum time to wait before forcing loading display for long operations (in milliseconds)
  final int? forceLoadingAfter;
  
  /// Whether to disable debouncing entirely (useful for debugging)
  final bool disableDebouncing;

  const DebouncedLoadingConfig({
    this.minimumDelay = 150,
    this.forceLoadingAfter,
    this.disableDebouncing = false,
  });

  /// Quick operations configuration - higher delay to prevent flashing
  static const quick = DebouncedLoadingConfig(
    minimumDelay: 200,
    forceLoadingAfter: 1000,
  );

  /// Medium operations configuration - balanced delay
  static const medium = DebouncedLoadingConfig(
    minimumDelay: 100,
    forceLoadingAfter: 2000,
  );

  /// Slow operations configuration - minimal delay
  static const slow = DebouncedLoadingConfig(
    minimumDelay: 50,
    forceLoadingAfter: null,
  );

  /// Immediate loading - no debouncing (for critical operations)
  static const immediate = DebouncedLoadingConfig(
    minimumDelay: 0,
    disableDebouncing: true,
  );
}

/// State for tracking debounced loading operations
class DebouncedLoadingState {
  final bool isOperationActive;
  final bool shouldShowLoading;
  final DateTime? operationStartTime;
  final Timer? debounceTimer;
  final DebouncedLoadingConfig config;

  const DebouncedLoadingState({
    required this.isOperationActive,
    required this.shouldShowLoading,
    this.operationStartTime,
    this.debounceTimer,
    required this.config,
  });

  factory DebouncedLoadingState.initial(DebouncedLoadingConfig config) {
    return DebouncedLoadingState(
      isOperationActive: false,
      shouldShowLoading: false,
      config: config,
    );
  }

  DebouncedLoadingState copyWith({
    bool? isOperationActive,
    bool? shouldShowLoading,
    DateTime? operationStartTime,
    Timer? debounceTimer,
    DebouncedLoadingConfig? config,
  }) {
    return DebouncedLoadingState(
      isOperationActive: isOperationActive ?? this.isOperationActive,
      shouldShowLoading: shouldShowLoading ?? this.shouldShowLoading,
      operationStartTime: operationStartTime ?? this.operationStartTime,
      debounceTimer: debounceTimer ?? this.debounceTimer,
      config: config ?? this.config,
    );
  }
}

/// Notifier for managing debounced loading state
class DebouncedLoadingNotifier extends StateNotifier<DebouncedLoadingState> {
  DebouncedLoadingNotifier(DebouncedLoadingConfig config) 
    : super(DebouncedLoadingState.initial(config));

  /// Start an operation with debounced loading
  void startOperation([String? operationDescription]) {
    // Cancel any existing timer
    state.debounceTimer?.cancel();

    if (state.config.disableDebouncing) {
      // Show loading immediately if debouncing is disabled
      state = state.copyWith(
        isOperationActive: true,
        shouldShowLoading: true,
        operationStartTime: DateTime.now(),
      );
      
      // Announce operation start for immediate loading
      _announceOperationStart(operationDescription);
      return;
    }

    // Start the operation but don't show loading yet
    state = state.copyWith(
      isOperationActive: true,
      shouldShowLoading: false,
      operationStartTime: DateTime.now(),
    );

    // Set timer to show loading after delay
    final timer = Timer(
      Duration(milliseconds: state.config.minimumDelay),
      () {
        // Only show loading if operation is still active
        if (state.isOperationActive) {
          state = state.copyWith(
            shouldShowLoading: true,
            debounceTimer: null,
          );
          
          // Announce loading state after debounce delay
          _announceLoadingStart(operationDescription);
        }
      },
    );

    state = state.copyWith(debounceTimer: timer);
  }
  
  /// Announce operation start to screen readers
  void _announceOperationStart(String? operationDescription) {
    final message = operationDescription != null 
        ? 'Starting: $operationDescription'
        : 'Operation starting';
    
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: Assertiveness.polite,
    );
  }
  
  /// Announce loading state to screen readers
  void _announceLoadingStart(String? operationDescription) {
    final message = operationDescription != null 
        ? 'Loading: $operationDescription'
        : 'Loading in progress';
    
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: Assertiveness.polite,
    );
  }

  /// Complete the operation and hide loading
  void completeOperation([String? operationDescription, bool announceCompletion = false]) {
    // Cancel any pending timer
    state.debounceTimer?.cancel();
    
    // Announce completion if requested and loading was shown
    if (announceCompletion && state.shouldShowLoading) {
      _announceOperationComplete(operationDescription);
    }

    state = state.copyWith(
      isOperationActive: false,
      shouldShowLoading: false,
      operationStartTime: null,
      debounceTimer: null,
    );
  }
  
  /// Announce operation completion to screen readers
  void _announceOperationComplete(String? operationDescription) {
    final message = operationDescription != null 
        ? 'Completed: $operationDescription'
        : 'Operation completed';
    
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: Assertiveness.polite,
    );
  }

  /// Get the operation duration in milliseconds
  int? get operationDurationMs {
    final startTime = state.operationStartTime;
    if (startTime == null) return null;
    return DateTime.now().difference(startTime).inMilliseconds;
  }

  @override
  void dispose() {
    state.debounceTimer?.cancel();
    super.dispose();
  }
  
  /// Force complete any pending operation (useful for cleanup)
  void forceComplete() {
    state.debounceTimer?.cancel();
    state = state.copyWith(
      isOperationActive: false,
      shouldShowLoading: false,
      operationStartTime: null,
      debounceTimer: null,
    );
  }
}

/// Provider factory for creating debounced loading notifiers with specific configurations
final debouncedLoadingProvider = StateNotifierProvider.family<DebouncedLoadingNotifier, DebouncedLoadingState, String>(
  (ref, operationKey) {
    // Default configuration - can be overridden
    return DebouncedLoadingNotifier(DebouncedLoadingConfig.medium);
  },
);

/// Provider for quick operations (assignment changes, simple saves)
final quickOperationLoadingProvider = StateNotifierProvider.family<DebouncedLoadingNotifier, DebouncedLoadingState, String>(
  (ref, operationKey) => DebouncedLoadingNotifier(DebouncedLoadingConfig.quick),
);

/// Provider for medium operations (form submissions, updates)
final mediumOperationLoadingProvider = StateNotifierProvider.family<DebouncedLoadingNotifier, DebouncedLoadingState, String>(
  (ref, operationKey) => DebouncedLoadingNotifier(DebouncedLoadingConfig.medium),
);

/// Provider for slow operations (bulk operations, file uploads)
final slowOperationLoadingProvider = StateNotifierProvider.family<DebouncedLoadingNotifier, DebouncedLoadingState, String>(
  (ref, operationKey) => DebouncedLoadingNotifier(DebouncedLoadingConfig.slow),
);

/// Provider for immediate operations (critical operations that must show loading)
final immediateOperationLoadingProvider = StateNotifierProvider.family<DebouncedLoadingNotifier, DebouncedLoadingState, String>(
  (ref, operationKey) => DebouncedLoadingNotifier(DebouncedLoadingConfig.immediate),
);

/// Mixin to simplify debounced loading operations in widgets
mixin DebouncedLoadingMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Execute an operation with debounced loading
  Future<R> executeWithDebouncedLoading<R>({
    required String operationKey,
    required Future<R> Function() operation,
    DebouncedLoadingConfig? config,
    String? operationDescription,
    bool announceCompletion = false,
  }) async {
    // Get the appropriate provider based on config
    final provider = _getProviderForConfig(operationKey, config);
    final notifier = ref.read(provider.notifier);

    try {
      // Start the debounced loading
      notifier.startOperation(operationDescription);
      
      // Execute the operation
      final result = await operation();
      
      // Complete the loading (this will hide indicators)
      notifier.completeOperation(operationDescription, announceCompletion);
      
      return result;
    } catch (error) {
      // Make sure to complete loading even on error
      notifier.completeOperation(operationDescription);
      rethrow;
    }
  }

  /// Get the appropriate provider based on configuration
  StateNotifierProvider<DebouncedLoadingNotifier, DebouncedLoadingState> _getProviderForConfig(
    String operationKey,
    DebouncedLoadingConfig? config,
  ) {
    if (config == null) return debouncedLoadingProvider(operationKey);
    
    if (config == DebouncedLoadingConfig.quick) {
      return quickOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.medium) {
      return mediumOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.slow) {
      return slowOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.immediate) {
      return immediateOperationLoadingProvider(operationKey);
    }
    
    return debouncedLoadingProvider(operationKey);
  }

  /// Watch if an operation should show loading
  bool watchShouldShowLoading(String operationKey, {DebouncedLoadingConfig? config}) {
    final provider = _getProviderForConfig(operationKey, config);
    final state = ref.watch(provider);
    return state.shouldShowLoading;
  }

  /// Watch if an operation is active (regardless of loading display)
  bool watchIsOperationActive(String operationKey, {DebouncedLoadingConfig? config}) {
    final provider = _getProviderForConfig(operationKey, config);
    final state = ref.watch(provider);
    return state.isOperationActive;
  }
}

/// Extension methods for easier usage in ConsumerWidgets
extension DebouncedLoadingRef on WidgetRef {
  /// Execute an operation with debounced loading
  Future<R> executeWithDebouncedLoading<R>({
    required String operationKey,
    required Future<R> Function() operation,
    DebouncedLoadingConfig config = DebouncedLoadingConfig.medium,
    String? operationDescription,
    bool announceCompletion = false,
  }) async {
    final provider = _getProviderForConfig(operationKey, config);
    final notifier = read(provider.notifier);

    try {
      notifier.startOperation(operationDescription);
      final result = await operation();
      notifier.completeOperation(operationDescription, announceCompletion);
      return result;
    } catch (error) {
      notifier.completeOperation(operationDescription);
      rethrow;
    }
  }

  /// Check if operation should show loading
  bool shouldShowLoading(String operationKey, {DebouncedLoadingConfig config = DebouncedLoadingConfig.medium}) {
    final provider = _getProviderForConfig(operationKey, config);
    return watch(provider).shouldShowLoading;
  }

  /// Check if operation is active
  bool isOperationActive(String operationKey, {DebouncedLoadingConfig config = DebouncedLoadingConfig.medium}) {
    final provider = _getProviderForConfig(operationKey, config);
    return watch(provider).isOperationActive;
  }

  StateNotifierProvider<DebouncedLoadingNotifier, DebouncedLoadingState> _getProviderForConfig(
    String operationKey,
    DebouncedLoadingConfig config,
  ) {
    if (config == DebouncedLoadingConfig.quick) {
      return quickOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.medium) {
      return mediumOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.slow) {
      return slowOperationLoadingProvider(operationKey);
    } else if (config == DebouncedLoadingConfig.immediate) {
      return immediateOperationLoadingProvider(operationKey);
    }
    return debouncedLoadingProvider(operationKey);
  }
}