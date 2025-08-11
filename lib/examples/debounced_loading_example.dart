import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/loading/debounced_loading_system.dart';
import '../widgets/loading/debounced_loading_widgets.dart';

/// Example page demonstrating the debounced loading system
/// 
/// This example shows:
/// - Quick operations that prevent loading flashes (< 200ms delay)
/// - Medium operations with balanced delay (< 100ms delay)  
/// - Slow operations with minimal delay (< 50ms delay)
/// - Immediate operations with no debouncing
/// - Various widget types: buttons, icon buttons, overlays
class DebouncedLoadingExamplePage extends ConsumerWidget {
  const DebouncedLoadingExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debounced Loading Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Quick Operations (200ms delay)'),
            const SizedBox(height: 8),
            _buildQuickOperationsSection(context),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Medium Operations (100ms delay)'),
            const SizedBox(height: 8),
            _buildMediumOperationsSection(context),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Slow Operations (50ms delay)'),
            const SizedBox(height: 8),
            _buildSlowOperationsSection(context),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Immediate Operations (no delay)'),
            const SizedBox(height: 8),
            _buildImmediateOperationsSection(context),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Comparison: Traditional vs Debounced'),
            const SizedBox(height: 8),
            _buildComparisonSection(context, ref),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Overlay Examples'),
            const SizedBox(height: 8),
            _buildOverlaySection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuickOperationsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best for: Assignment quantity changes, simple toggles, rapid interactions',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DebouncedLoadingButton.quick(
                  operationKey: 'quick_save_1',
                  onPressed: () => _simulateQuickOperation(),
                  child: const Text('Quick Save'),
                ),
                DebouncedLoadingIconButton.quick(
                  operationKey: 'quantity_plus',
                  icon: const Icon(Icons.add),
                  onPressed: () => _simulateQuickOperation(),
                  tooltip: 'Increase Quantity',
                ),
                DebouncedLoadingIconButton.quick(
                  operationKey: 'quantity_minus',
                  icon: const Icon(Icons.remove),
                  onPressed: () => _simulateQuickOperation(),
                  tooltip: 'Decrease Quantity',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumOperationsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best for: Form submissions, simple updates, moderate complexity operations',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DebouncedLoadingButton(
                  operationKey: 'medium_update_1',
                  config: DebouncedLoadingConfig.medium,
                  onPressed: () => _simulateMediumOperation(),
                  child: const Text('Update Item'),
                ),
                DebouncedLoadingButton(
                  operationKey: 'medium_save_1',
                  config: DebouncedLoadingConfig.medium,
                  onPressed: () => _simulateMediumOperation(),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlowOperationsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best for: Bulk operations, file uploads, complex operations that usually take time',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DebouncedLoadingButton(
                  operationKey: 'slow_bulk_1',
                  config: DebouncedLoadingConfig.slow,
                  onPressed: () => _simulateSlowOperation(),
                  child: const Text('Bulk Update'),
                ),
                DebouncedLoadingButton(
                  operationKey: 'slow_export_1',
                  config: DebouncedLoadingConfig.slow,
                  onPressed: () => _simulateSlowOperation(),
                  child: const Text('Export Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImmediateOperationsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best for: Critical operations that must always show feedback, error-prone operations',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DebouncedLoadingButton(
                  operationKey: 'immediate_delete_1',
                  config: DebouncedLoadingConfig.immediate,
                  onPressed: () => _simulateMediumOperation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete Item'),
                ),
                DebouncedLoadingButton(
                  operationKey: 'immediate_auth_1',
                  config: DebouncedLoadingConfig.immediate,
                  onPressed: () => _simulateMediumOperation(),
                  child: const Text('Authenticate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Click both buttons quickly to see the difference in loading behavior',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Traditional (shows immediately)'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Simulate traditional immediate loading
                          await _simulateQuickOperation();
                        },
                        child: const Text('Traditional Loading'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Debounced (waits 200ms)'),
                      const SizedBox(height: 8),
                      DebouncedLoadingButton.quick(
                        operationKey: 'comparison_debounced',
                        onPressed: () => _simulateQuickOperation(),
                        child: const Text('Debounced Loading'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlaySection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overlay examples with different debounce settings',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _showDebouncedOverlay(
                    context,
                    ref,
                    'quick_overlay',
                    DebouncedLoadingConfig.quick,
                    'Quick Operation...',
                  ),
                  child: const Text('Show Quick Overlay'),
                ),
                ElevatedButton(
                  onPressed: () => _showDebouncedOverlay(
                    context,
                    ref,
                    'medium_overlay',
                    DebouncedLoadingConfig.medium,
                    'Medium Operation...',
                  ),
                  child: const Text('Show Medium Overlay'),
                ),
                ElevatedButton(
                  onPressed: () => _showDebouncedOverlay(
                    context,
                    ref,
                    'slow_overlay',
                    DebouncedLoadingConfig.slow,
                    'Slow Operation...',
                  ),
                  child: const Text('Show Slow Overlay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Simulate a quick operation (50-150ms)
  Future<void> _simulateQuickOperation() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Simulate a medium operation (200-800ms)
  Future<void> _simulateMediumOperation() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Simulate a slow operation (1-3s)
  Future<void> _simulateSlowOperation() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Show a debounced loading overlay
  void _showDebouncedOverlay(
    BuildContext context,
    WidgetRef ref,
    String operationKey,
    DebouncedLoadingConfig config,
    String operation,
  ) {
    // Start the debounced loading
    final provider = _getDebouncedProvider(operationKey, config);
    final notifier = ref.read(provider.notifier);
    notifier.startOperation();

    // Show overlay that will respect debouncing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DebouncedLoadingOverlay(
        operationKey: operationKey,
        config: config,
        operation: operation,
        details: 'Testing ${config == DebouncedLoadingConfig.quick ? 'quick' : 
                             config == DebouncedLoadingConfig.medium ? 'medium' : 
                             config == DebouncedLoadingConfig.slow ? 'slow' : 'immediate'} debouncing...',
        child: Container(), // Empty child since we're in a dialog
      ),
    );

    // Simulate the operation and close
    Future.delayed(const Duration(milliseconds: 800), () {
      notifier.completeOperation();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  StateNotifierProvider<DebouncedLoadingNotifier, DebouncedLoadingState> _getDebouncedProvider(
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