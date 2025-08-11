import 'package:flutter/material.dart';

/// A standardized loading indicator for data loading states.
/// 
/// This widget provides consistent loading UI across the application,
/// following Material Design patterns with proper accessibility support.
/// 
/// Usage:
/// ```dart
/// // Basic usage
/// DataLoadingIndicator()
/// 
/// // With custom message
/// DataLoadingIndicator(message: 'Loading items...')
/// 
/// // As overlay
/// DataLoadingIndicator.overlay()
/// 
/// // Compact for cards
/// DataLoadingIndicator.compact()
/// ```
class DataLoadingIndicator extends StatelessWidget {
  /// Optional loading message to display
  final String? message;
  
  /// Whether to show as an overlay covering the content
  final bool isOverlay;
  
  /// Whether to use a compact layout (smaller size)
  final bool isCompact;
  
  /// Custom semantic label for accessibility
  final String? semanticsLabel;

  const DataLoadingIndicator({
    super.key,
    this.message,
    this.isOverlay = false,
    this.isCompact = false,
    this.semanticsLabel,
  });

  /// Creates a loading indicator suitable for overlaying content
  const DataLoadingIndicator.overlay({
    super.key,
    this.message,
    this.semanticsLabel,
  }) : isOverlay = true, isCompact = false;

  /// Creates a compact loading indicator for smaller spaces
  const DataLoadingIndicator.compact({
    super.key,
    this.message,
    this.semanticsLabel,
  }) : isOverlay = false, isCompact = true;

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    
    if (isOverlay) {
      return _buildOverlay(context, content);
    }
    
    return content;
  }

  /// Builds the main content with loading indicator and optional message
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final loadingLabel = semanticsLabel ?? (message != null ? 'Loading: $message' : 'Loading');
    
    return Semantics(
      liveRegion: true,
      label: loadingLabel,
      hint: 'Please wait while content loads',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: isCompact ? 24 : 36,
              height: isCompact ? 24 : 36,
              child: CircularProgressIndicator(
                strokeWidth: isCompact ? 2.5 : 3.0,
                semanticsLabel: loadingLabel,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: isCompact ? 8 : 16),
              Semantics(
                label: 'Loading message: $message',
                child: Text(
                  message!,
                  style: isCompact 
                    ? theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds overlay wrapper for covering existing content
  Widget _buildOverlay(BuildContext context, Widget content) {
    return Semantics(
      label: 'Loading overlay active',
      hint: 'Content is loading, please wait',
      container: true,
      child: Container(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        child: content,
      ),
    );
  }
}

/// A specialized loading indicator for lists and grids.
/// 
/// Shows placeholder items while data is loading to maintain layout structure.
class DataListLoadingIndicator extends StatelessWidget {
  /// Number of placeholder items to show
  final int itemCount;
  
  /// Height of each placeholder item
  final double itemHeight;
  
  /// Whether to show as cards
  final bool showAsCards;

  const DataListLoadingIndicator({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 72.0,
    this.showAsCards = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading list items',
      hint: 'Displaying $itemCount placeholder items while content loads',
      liveRegion: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _buildPlaceholderItem(context, index),
      ),
    );
  }

  Widget _buildPlaceholderItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final shimmerColor = theme.colorScheme.surfaceContainerHighest;
    
    Widget content = Semantics(
      label: 'Loading placeholder item ${index + 1} of $itemCount',
      child: Container(
        height: itemHeight,
        decoration: BoxDecoration(
          color: shimmerColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Leading placeholder (like item image)
            Container(
              margin: const EdgeInsets.all(12),
              width: itemHeight - 24,
              height: itemHeight - 24,
              decoration: BoxDecoration(
                color: shimmerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Content placeholder
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );

    if (showAsCards) {
      return Card(
        margin: EdgeInsets.zero,
        child: content,
      );
    }

    return content;
  }
}

/// Loading indicator specifically for grid layouts.
class DataGridLoadingIndicator extends StatelessWidget {
  /// Number of columns in the grid
  final int crossAxisCount;
  
  /// Number of placeholder items to show
  final int itemCount;
  
  /// Aspect ratio of each grid item
  final double childAspectRatio;

  const DataGridLoadingIndicator({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading grid items',
      hint: 'Displaying $itemCount placeholder items in $crossAxisCount columns while content loads',
      liveRegion: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildPlaceholderItem(context, index),
      ),
    );
  }

  Widget _buildPlaceholderItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final shimmerColor = theme.colorScheme.surfaceContainerHighest;
    final row = (index ~/ crossAxisCount) + 1;
    final col = (index % crossAxisCount) + 1;
    
    return Semantics(
      label: 'Loading placeholder item at row $row, column $col',
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            color: shimmerColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: shimmerColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: shimmerColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  color: shimmerColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}