import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A modal loading overlay for operations like create, update, delete.
/// 
/// This widget shows a modal overlay that prevents user interaction while
/// an operation is in progress, following the existing pattern established
/// in confirm_dialog.dart and other modal widgets.
/// 
/// Usage:
/// ```dart
/// // Show overlay for operation
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (context) => OperationLoadingOverlay(
///     operation: 'Saving item...',
///   ),
/// );
/// 
/// // Using with helper method
/// OperationLoadingOverlay.show(
///   context: context,
///   operation: 'Deleting items...',
/// );
/// ```
class OperationLoadingOverlay extends StatelessWidget {
  /// Description of the operation being performed
  final String operation;
  
  /// Whether the overlay can be dismissed by tapping outside
  final bool canDismiss;
  
  /// Custom progress value for determinate operations (0.0 to 1.0)
  final double? progress;
  
  /// Additional details about the operation
  final String? details;

  const OperationLoadingOverlay({
    super.key,
    required this.operation,
    this.canDismiss = false,
    this.progress,
    this.details,
  });

  /// Helper method to show the loading overlay
  static Future<T?> show<T>({
    required BuildContext context,
    required String operation,
    bool canDismiss = false,
    double? progress,
    String? details,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: canDismiss,
      builder: (context) => OperationLoadingOverlay(
        operation: operation,
        canDismiss: canDismiss,
        progress: progress,
        details: details,
      ),
    );
  }

  /// Helper method to show overlay and perform operation
  static Future<T> performOperation<T>({
    required BuildContext context,
    required String operation,
    required Future<T> Function() task,
    String? details,
  }) async {
    // Show overlay
    show<void>(
      context: context,
      operation: operation,
      details: details,
    );

    try {
      // Perform the operation
      final result = await task();
      
      // Close overlay
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      return result;
    } catch (error) {
      // Close overlay on error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadingMessage = details != null ? '$operation $details' : operation;
    
    // Announce operation start to screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        loadingMessage,
        TextDirection.ltr,
        assertiveness: Assertiveness.polite,
      );
    });
    
    return PopScope(
      canPop: canDismiss,
      child: Semantics(
        liveRegion: true,
        label: loadingMessage,
        hint: canDismiss ? 'Operation in progress, tap outside to dismiss' : 'Operation in progress, please wait',
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(
                minWidth: 280,
                maxWidth: 400,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProgressIndicator(context),
                  const SizedBox(height: 20),
                  _buildOperationText(context),
                  if (details != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailsText(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    if (progress != null) {
      // Determinate progress indicator
      final progressPercent = (progress! * 100).round();
      return Semantics(
        label: 'Progress: $progressPercent percent complete',
        value: '$progressPercent%',
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: progress,
            semanticsLabel: 'Operation progress: $progressPercent%',
            semanticsValue: '$progressPercent%',
          ),
        ),
      );
    }
    
    // Indeterminate progress indicator
    return Semantics(
      label: 'Operation in progress',
      hint: 'Loading indicator',
      child: const SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          semanticsLabel: 'Operation in progress',
        ),
      ),
    );
  }

  Widget _buildOperationText(BuildContext context) {
    return Semantics(
      label: 'Operation: $operation',
      child: Text(
        operation,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDetailsText(BuildContext context) {
    return Semantics(
      label: 'Operation details: ${details!}',
      child: Text(
        details!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// A simplified loading overlay for quick operations
class SimpleLoadingOverlay extends StatelessWidget {
  /// Message to display (optional)
  final String? message;

  const SimpleLoadingOverlay({
    super.key,
    this.message,
  });

  /// Helper method to show simple loading overlay
  static Future<T?> show<T>({
    required BuildContext context,
    String? message,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleLoadingOverlay(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingMessage = message ?? 'Loading';
    
    // Announce loading to screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        loadingMessage,
        TextDirection.ltr,
        assertiveness: Assertiveness.polite,
      );
    });
    
    return PopScope(
      canPop: false,
      child: Semantics(
        liveRegion: true,
        label: loadingMessage,
        hint: 'Operation in progress, please wait',
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Loading indicator',
                    hint: 'Operation in progress',
                    child: const CircularProgressIndicator(
                      semanticsLabel: 'Loading',
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Loading message: $message',
                      child: Text(
                        message!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension methods for easier loading overlay usage
extension LoadingOverlayContext on BuildContext {
  /// Show a loading overlay with operation description
  Future<T?> showLoadingOverlay<T>({
    required String operation,
    String? details,
    bool canDismiss = false,
  }) {
    return OperationLoadingOverlay.show<T>(
      context: this,
      operation: operation,
      details: details,
      canDismiss: canDismiss,
    );
  }

  /// Show a simple loading overlay
  Future<T?> showSimpleLoading<T>({String? message}) {
    return SimpleLoadingOverlay.show<T>(
      context: this,
      message: message,
    );
  }

  /// Perform an operation with loading overlay
  Future<T> performWithLoading<T>({
    required String operation,
    required Future<T> Function() task,
    String? details,
  }) {
    return OperationLoadingOverlay.performOperation<T>(
      context: this,
      operation: operation,
      task: task,
      details: details,
    );
  }
}