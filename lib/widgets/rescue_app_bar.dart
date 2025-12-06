import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment_config.dart';
import '../config/environment_detector.dart';
import '../config/org_provider.dart';
import '../config/detected_environment_provider.dart';

/// Custom AppBar that displays an environment indicator chip.
///
/// Drop-in replacement for Flutter's AppBar. Automatically adds a small
/// colored chip next to the title showing the current environment (STAGING/PROD).
///
/// Usage:
/// ```dart
/// // With String title
/// RescueAppBar(
///   title: 'My Page',
///   actions: [MyAction()],
/// )
///
/// // With Widget title
/// RescueAppBar(
///   title: Row(children: [Text('Custom'), Icon(Icons.star)]),
///   actions: [MyAction()],
/// )
/// ```
class RescueAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final dynamic title; // Can be String or Widget
  final List<Widget>? actions;

  const RescueAppBar({Key? key, required this.title, this.actions})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(currentEnvironmentProvider);
    final detection = ref.watch(detectedEnvironmentProvider);

    // Convert title to Widget if it's a String
    Widget titleWidget;
    if (title is String) {
      titleWidget = Text(title);
    } else if (title is Widget) {
      titleWidget = title;
    } else {
      titleWidget = Text(title.toString());
    }

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget,
          const SizedBox(width: 12),
          _buildEnvironmentChips(environment, detection),
        ],
      ),
      actions: actions,
    );
  }

  /// Builds environment chip(s) based on detection state.
  /// Shows single chip if no mismatch, two chips if mismatch detected.
  Widget _buildEnvironmentChips(String environment, EnvironmentDetectionResult detection) {
    final chipConfig = getEnvironmentChipConfig(environment);

    // If no mismatch, show single chip (current behavior)
    if (!detection.hasMismatch) {
      return _EnvironmentChip(config: chipConfig);
    }

    // If mismatch detected, show two chips side-by-side
    final warningConfig = getEnvironmentWarningChipConfig(detection.actualEnv);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EnvironmentChip(config: chipConfig),
        const SizedBox(width: 8),
        _EnvironmentChip(
          config: EnvironmentChipConfig(
            label: warningConfig.label,
            backgroundColor: warningConfig.backgroundColor,
            textColor: warningConfig.textColor,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Small chip displaying the environment name.
class _EnvironmentChip extends StatelessWidget {
  final EnvironmentChipConfig config;

  const _EnvironmentChip({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
