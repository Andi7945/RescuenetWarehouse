import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A generic widget that handles AsyncValue states from Riverpod providers.
///
/// This widget follows the established pattern from auth providers and provides
/// consistent loading, error, and data states across the application.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<Item>>(
///   value: ref.watch(itemsProvider),
///   data: (items) => ItemGrid(items: items),
///   loading: () => DataLoadingIndicator(),
///   error: (error, stackTrace) => ErrorRetryWidget(
///     error: error,
///     onRetry: () => ref.refresh(itemsProvider),
///   ),
/// )
/// ```
class AsyncValueBuilder<T> extends StatelessWidget {
  /// The AsyncValue to handle
  final AsyncValue<T> value;

  /// Widget to show when data is available
  final Widget Function(T data) data;

  /// Widget to show when loading (optional, shows CircularProgressIndicator by default)
  final Widget Function()? loading;

  /// Widget to show when there's an error (optional, shows basic error message by default)
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  /// Whether to show loading state when data is available but refreshing
  /// Defaults to false to prevent flickering during refreshes
  final bool showLoadingOnRefresh;

  const AsyncValueBuilder({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.showLoadingOnRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => this.data(data),
      loading: () => loading?.call() ?? _defaultLoading(context),
      error: (err, stackTrace) =>
          error?.call(err, stackTrace) ?? _defaultError(context, err),
    );
  }

  /// Default loading widget when none provided
  Widget _defaultLoading(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Loading data',
      child: const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading data'),
      ),
    );
  }

  /// Default error widget when none provided
  Widget _defaultError(BuildContext context, Object error) {
    final errorMessage = 'Error occurred: ${error.toString()}';

    // Announce error to screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        errorMessage,
        TextDirection.ltr,
        assertiveness: Assertiveness.assertive,
      );
    });

    return Semantics(
      liveRegion: true,
      label: errorMessage,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
              semanticLabel: 'Error occurred',
            ),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Error details: ${error.toString()}',
              child: Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Specialized version of AsyncValueBuilder for optional data types.
///
/// Handles the common pattern where AsyncValue of nullable T might contain null data,
/// which is different from loading state.
class AsyncValueNullableBuilder<T> extends StatelessWidget {
  /// The AsyncValue to handle
  final AsyncValue<T?> value;

  /// Widget to show when data is available and not null
  final Widget Function(T data) data;

  /// Widget to show when data is null (optional, shows "No data" message by default)
  final Widget Function()? noData;

  /// Widget to show when loading (optional, shows CircularProgressIndicator by default)
  final Widget Function()? loading;

  /// Widget to show when there's an error (optional, shows basic error message by default)
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  const AsyncValueNullableBuilder({
    super.key,
    required this.value,
    required this.data,
    this.noData,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        if (data == null) {
          return noData?.call() ?? _defaultNoData(context);
        }
        return this.data(data);
      },
      loading: () => loading?.call() ?? _defaultLoading(context),
      error: (err, stackTrace) =>
          error?.call(err, stackTrace) ?? _defaultError(context, err),
    );
  }

  /// Default no data widget when none provided
  Widget _defaultNoData(BuildContext context) {
    const message = 'No data available';

    return Semantics(
      liveRegion: true,
      label: message,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              semanticLabel: 'No data available',
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Default loading widget when none provided
  Widget _defaultLoading(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Loading data',
      child: const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading data'),
      ),
    );
  }

  /// Default error widget when none provided
  Widget _defaultError(BuildContext context, Object error) {
    final errorMessage = 'Error occurred: ${error.toString()}';

    // Announce error to screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        errorMessage,
        TextDirection.ltr,
        assertiveness: Assertiveness.assertive,
      );
    });

    return Semantics(
      liveRegion: true,
      label: errorMessage,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
              semanticLabel: 'Error occurred',
            ),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Error details: ${error.toString()}',
              child: Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
