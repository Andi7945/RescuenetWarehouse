import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'debounced_loading_system.dart';
import 'data_loading_indicator.dart';

/// A debounced version of DataLoadingIndicator that only shows after a delay
class DebouncedLoadingIndicator extends ConsumerWidget {
  /// Unique key for the operation
  final String operationKey;
  
  /// Loading configuration (quick, medium, slow, immediate)
  final DebouncedLoadingConfig config;
  
  /// Optional loading message to display
  final String? message;
  
  /// Whether to show as an overlay covering the content
  final bool isOverlay;
  
  /// Whether to use a compact layout (smaller size)
  final bool isCompact;
  
  /// Custom semantic label for accessibility
  final String? semanticsLabel;
  
  /// Widget to show when not loading
  final Widget? child;

  const DebouncedLoadingIndicator({
    super.key,
    required this.operationKey,
    this.config = DebouncedLoadingConfig.medium,
    this.message,
    this.isOverlay = false,
    this.isCompact = false,
    this.semanticsLabel,
    this.child,
  });

  /// Creates a loading indicator for quick operations (assignment changes, etc.)
  const DebouncedLoadingIndicator.quick({
    super.key,
    required this.operationKey,
    this.message,
    this.isOverlay = false,
    this.isCompact = false,
    this.semanticsLabel,
    this.child,
  }) : config = DebouncedLoadingConfig.quick;

  /// Creates a loading indicator suitable for overlaying content
  const DebouncedLoadingIndicator.overlay({
    super.key,
    required this.operationKey,
    this.config = DebouncedLoadingConfig.medium,
    this.message,
    this.semanticsLabel,
    this.child,
  }) : isOverlay = true, isCompact = false;

  /// Creates a compact loading indicator for smaller spaces
  const DebouncedLoadingIndicator.compact({
    super.key,
    required this.operationKey,
    this.config = DebouncedLoadingConfig.medium,
    this.message,
    this.semanticsLabel,
    this.child,
  }) : isOverlay = false, isCompact = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowLoading = ref.shouldShowLoading(operationKey, config: config);
    
    if (!shouldShowLoading) {
      return child ?? const SizedBox.shrink();
    }

    return Semantics(
      liveRegion: true,
      label: semanticsLabel ?? (message != null ? 'Loading: $message' : 'Loading'),
      child: DataLoadingIndicator(
        message: message,
        isOverlay: isOverlay,
        isCompact: isCompact,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}

/// A debounced button that shows loading state with proper timing
class DebouncedLoadingButton extends ConsumerWidget {
  /// Unique key for the operation
  final String operationKey;
  
  /// Loading configuration
  final DebouncedLoadingConfig config;
  
  /// Button text or widget
  final Widget child;
  
  /// Callback when button is pressed
  final Future<void> Function()? onPressed;
  
  /// Button style
  final ButtonStyle? style;
  
  /// Icon to show during loading (optional)
  final Widget? loadingIcon;
  
  /// Whether to disable button when operation is active
  final bool disableWhenActive;
  
  /// Whether to show loading icon instead of progress indicator
  final bool showLoadingIcon;

  const DebouncedLoadingButton({
    super.key,
    required this.operationKey,
    required this.child,
    required this.onPressed,
    this.config = DebouncedLoadingConfig.quick,
    this.style,
    this.loadingIcon,
    this.disableWhenActive = true,
    this.showLoadingIcon = false,
  });

  /// Creates a button optimized for quick operations
  const DebouncedLoadingButton.quick({
    super.key,
    required this.operationKey,
    required this.child,
    required this.onPressed,
    this.style,
    this.loadingIcon,
    this.disableWhenActive = true,
    this.showLoadingIcon = false,
  }) : config = DebouncedLoadingConfig.quick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowLoading = ref.shouldShowLoading(operationKey, config: config);
    final isActive = ref.isOperationActive(operationKey, config: config);
    
    // Determine if button should be disabled
    final isDisabled = onPressed == null || (disableWhenActive && isActive);
    
    // Choose what to show based on loading state
    Widget buttonChild;
    String buttonSemanticLabel;
    
    if (shouldShowLoading) {
      if (showLoadingIcon && loadingIcon != null) {
        buttonChild = loadingIcon!;
        buttonSemanticLabel = 'Button loading';
      } else {
        buttonChild = Semantics(
          label: 'Loading indicator',
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
              semanticsLabel: 'Button loading',
            ),
          ),
        );
        buttonSemanticLabel = 'Button loading, please wait';
      }
    } else {
      buttonChild = child;
      buttonSemanticLabel = 'Button';
    }

    return Semantics(
      button: true,
      label: buttonSemanticLabel,
      hint: isDisabled 
          ? (shouldShowLoading ? 'Loading in progress' : 'Button disabled')
          : 'Tap to perform action',
      enabled: !isDisabled,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _handlePress(ref),
        style: style,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: buttonChild,
        ),
      ),
    );
  }

  Future<void> _handlePress(WidgetRef ref) async {
    if (onPressed == null) return;

    await ref.executeWithDebouncedLoading(
      operationKey: operationKey,
      config: config,
      operation: onPressed!,
      operationDescription: 'Button action',
      announceCompletion: false,
    );
  }
}

/// A debounced icon button with loading state
class DebouncedLoadingIconButton extends ConsumerWidget {
  /// Unique key for the operation
  final String operationKey;
  
  /// Loading configuration
  final DebouncedLoadingConfig config;
  
  /// Icon to display normally
  final Widget icon;
  
  /// Loading widget to show during operation (defaults to CircularProgressIndicator)
  final Widget? loadingWidget;
  
  /// Callback when button is pressed
  final Future<void> Function()? onPressed;
  
  /// Button style
  final ButtonStyle? style;
  
  /// Icon size
  final double? iconSize;
  
  /// Whether to disable button when operation is active
  final bool disableWhenActive;
  
  /// Tooltip text
  final String? tooltip;

  const DebouncedLoadingIconButton({
    super.key,
    required this.operationKey,
    required this.icon,
    required this.onPressed,
    this.config = DebouncedLoadingConfig.quick,
    this.loadingWidget,
    this.style,
    this.iconSize,
    this.disableWhenActive = true,
    this.tooltip,
  });

  /// Creates an icon button optimized for quick operations
  const DebouncedLoadingIconButton.quick({
    super.key,
    required this.operationKey,
    required this.icon,
    required this.onPressed,
    this.loadingWidget,
    this.style,
    this.iconSize,
    this.disableWhenActive = true,
    this.tooltip,
  }) : config = DebouncedLoadingConfig.quick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowLoading = ref.shouldShowLoading(operationKey, config: config);
    final isActive = ref.isOperationActive(operationKey, config: config);
    
    // Determine if button should be disabled
    final isDisabled = onPressed == null || (disableWhenActive && isActive);
    
    // Choose what to show based on loading state
    Widget buttonIcon;
    String iconSemanticLabel;
    
    if (shouldShowLoading) {
      buttonIcon = loadingWidget ?? Semantics(
        label: 'Loading indicator',
        child: SizedBox(
          width: (iconSize ?? 24) * 0.7,
          height: (iconSize ?? 24) * 0.7,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDisabled ? Colors.grey : null,
            semanticsLabel: 'Icon button loading',
          ),
        ),
      );
      iconSemanticLabel = 'Icon button loading, please wait';
    } else {
      buttonIcon = icon;
      iconSemanticLabel = tooltip ?? 'Icon button';
    }

    final button = Semantics(
      button: true,
      label: iconSemanticLabel,
      hint: isDisabled 
          ? (shouldShowLoading ? 'Loading in progress' : 'Button disabled')
          : 'Tap to perform action',
      enabled: !isDisabled,
      child: IconButton(
        onPressed: isDisabled ? null : () => _handlePress(ref),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: buttonIcon,
        ),
        style: style,
        iconSize: iconSize,
        tooltip: null, // Remove tooltip since we're handling semantics
      ),
    );

    return button;
  }

  Future<void> _handlePress(WidgetRef ref) async {
    if (onPressed == null) return;

    await ref.executeWithDebouncedLoading(
      operationKey: operationKey,
      config: config,
      operation: onPressed!,
      operationDescription: 'Button action',
      announceCompletion: false,
    );
  }
}

/// A loading overlay that respects debounced timing
class DebouncedLoadingOverlay extends ConsumerWidget {
  /// Unique key for the operation
  final String operationKey;
  
  /// Loading configuration
  final DebouncedLoadingConfig config;
  
  /// Description of the operation being performed
  final String operation;
  
  /// Additional details about the operation
  final String? details;
  
  /// Child widget to overlay
  final Widget child;
  
  /// Whether the overlay can be dismissed
  final bool canDismiss;

  const DebouncedLoadingOverlay({
    super.key,
    required this.operationKey,
    required this.operation,
    required this.child,
    this.config = DebouncedLoadingConfig.medium,
    this.details,
    this.canDismiss = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowLoading = ref.shouldShowLoading(operationKey, config: config);
    
    if (!shouldShowLoading) {
      return child;
    }

    final loadingMessage = details != null ? '$operation $details' : operation;

    return Semantics(
      liveRegion: true,
      label: 'Loading overlay: $loadingMessage',
      hint: canDismiss ? 'Tap outside to dismiss' : 'Please wait for operation to complete',
      child: Stack(
        children: [
          ExcludeSemantics(child: child), // Exclude underlying content from semantics
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
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
                      Semantics(
                        label: 'Loading indicator',
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Operation in progress',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        label: 'Operation: $operation',
                        child: Text(
                          operation,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (details != null) ...[
                        const SizedBox(height: 8),
                        Semantics(
                          label: 'Details: ${details!}',
                          child: Text(
                            details!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        ],
      ),
    );
  }
}

/// Widget that conditionally shows child or loading based on debounced state
class DebouncedLoadingWrapper extends ConsumerWidget {
  /// Unique key for the operation
  final String operationKey;
  
  /// Loading configuration
  final DebouncedLoadingConfig config;
  
  /// Widget to show when not loading
  final Widget child;
  
  /// Widget to show when loading (defaults to DataLoadingIndicator)
  final Widget? loadingWidget;

  const DebouncedLoadingWrapper({
    super.key,
    required this.operationKey,
    required this.child,
    this.config = DebouncedLoadingConfig.medium,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowLoading = ref.shouldShowLoading(operationKey, config: config);
    
    if (shouldShowLoading) {
      return Semantics(
        liveRegion: true,
        label: 'Content loading',
        hint: 'Please wait while content loads',
        child: loadingWidget ?? const DataLoadingIndicator(),
      );
    }
    
    return child;
  }
}