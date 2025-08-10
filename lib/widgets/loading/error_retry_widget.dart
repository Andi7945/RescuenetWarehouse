import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A widget that displays error messages with retry functionality.
/// 
/// This widget provides consistent error handling UI across the application,
/// following the patterns established in the authentication system and
/// providing accessibility support.
/// 
/// Usage:
/// ```dart
/// ErrorRetryWidget(
///   error: error,
///   onRetry: () => ref.refresh(dataProvider),
/// )
/// 
/// // With custom message
/// ErrorRetryWidget.withMessage(
///   message: 'Failed to load items',
///   onRetry: () => ref.refresh(itemsProvider),
/// )
/// 
/// // For specific error types
/// ErrorRetryWidget.forFirebaseError(
///   error: firebaseError,
///   onRetry: () => ref.refresh(dataProvider),
/// )
/// ```
class ErrorRetryWidget extends StatelessWidget {
  /// The error object to display
  final Object? error;
  
  /// Custom error message to override default error display
  final String? message;
  
  /// Callback function to retry the failed operation
  final VoidCallback? onRetry;
  
  /// Whether to show detailed error information (useful for debugging)
  final bool showDetails;
  
  /// Custom retry button text
  final String? retryText;
  
  /// Whether to show the error in compact mode (smaller layout)
  final bool isCompact;

  const ErrorRetryWidget({
    super.key,
    this.error,
    this.message,
    this.onRetry,
    this.showDetails = false,
    this.retryText,
    this.isCompact = false,
  });

  /// Creates an error widget with a custom message
  const ErrorRetryWidget.withMessage({
    super.key,
    required String this.message,
    this.onRetry,
    this.retryText,
    this.isCompact = false,
  }) : error = null, showDetails = false;

  /// Creates an error widget specifically for Firebase errors
  const ErrorRetryWidget.forFirebaseError({
    super.key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
    this.retryText,
    this.isCompact = false,
  }) : message = null;

  /// Creates a compact error widget for smaller spaces
  const ErrorRetryWidget.compact({
    super.key,
    this.error,
    this.message,
    this.onRetry,
    this.showDetails = false,
    this.retryText,
  }) : isCompact = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildErrorIcon(context),
            SizedBox(height: isCompact ? 12 : 16),
            _buildErrorMessage(context),
            if (showDetails && error != null) ...[
              SizedBox(height: isCompact ? 8 : 12),
              _buildErrorDetails(context),
            ],
            if (onRetry != null) ...[
              SizedBox(height: isCompact ? 16 : 24),
              _buildRetryButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    return Icon(
      Icons.error_outline,
      size: isCompact ? 32 : 48,
      color: Theme.of(context).colorScheme.error,
      semanticLabel: 'Error occurred',
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    final theme = Theme.of(context);
    final displayMessage = message ?? _getErrorMessage(error);
    
    return Text(
      displayMessage,
      style: isCompact 
        ? theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          )
        : theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
      textAlign: TextAlign.center,
      semanticsLabel: displayMessage,
    );
  }

  Widget _buildErrorDetails(BuildContext context) {
    final theme = Theme.of(context);
    final errorDetails = error.toString();
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        errorDetails,
        style: isCompact 
          ? theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontFamily: 'monospace',
            )
          : theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontFamily: 'monospace',
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    final theme = Theme.of(context);
    final buttonText = retryText ?? 'Try Again';
    
    if (isCompact) {
      return TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 16),
        label: Text(buttonText),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          textStyle: theme.textTheme.labelMedium,
        ),
      );
    }
    
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh, size: 20),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  /// Extracts user-friendly error message from error object
  String _getErrorMessage(Object? error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    // Handle Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _getFirebaseAuthErrorMessage(error);
    }

    // Handle generic Firebase errors
    if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error);
    }

    // Handle network errors
    if (error.toString().contains('SocketException') || 
        error.toString().contains('NetworkException')) {
      return 'Network connection error. Please check your internet connection.';
    }

    // Handle timeout errors
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }

    // Default to string representation
    return 'An error occurred: ${error.toString()}';
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return error.message ?? 'Authentication error occurred.';
    }
  }

  String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'The data already exists.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'failed-precondition':
        return 'Operation failed due to current system state.';
      case 'aborted':
        return 'Operation was aborted. Please try again.';
      case 'out-of-range':
        return 'Operation was attempted on invalid range.';
      case 'unimplemented':
        return 'This operation is not supported.';
      case 'internal':
        return 'Internal server error. Please try again later.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please try again later.';
      case 'deadline-exceeded':
        return 'Operation timed out. Please try again.';
      case 'unauthenticated':
        return 'Authentication required. Please sign in again.';
      default:
        return error.message ?? 'A service error occurred.';
    }
  }
}

/// A banner widget for non-critical error messages
class ErrorBanner extends StatelessWidget {
  /// Error message to display
  final String message;
  
  /// Callback to retry the operation
  final VoidCallback? onRetry;
  
  /// Callback to dismiss the banner
  final VoidCallback? onDismiss;
  
  /// Icon to show with the error
  final IconData? icon;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.error,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.warning_amber_outlined,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                textStyle: theme.textTheme.labelMedium,
              ),
              child: const Text('Retry'),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              color: theme.colorScheme.error,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}