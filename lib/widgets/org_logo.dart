import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/config/org_provider.dart';

enum LogoSize {
  small,  // Navigation drawer, compact spaces
  large,  // Login screen, prominent display
}

/// Displays the current organization's logo with automatic size selection.
///
/// Uses the organization configuration from [currentOrgProvider] to select
/// the appropriate logo asset. Logos are required in org config - no fallbacks.
class OrgLogo extends ConsumerWidget {
  final LogoSize size;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  const OrgLogo({
    super.key,
    required this.size,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  /// Convenience constructor for small logos (navigation, headers)
  const OrgLogo.small({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
    this.width,
    this.height,
  }) : size = LogoSize.small;

  /// Convenience constructor for large logos (login, splash)
  const OrgLogo.large({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  }) : size = LogoSize.large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final org = ref.watch(currentOrgProvider);

    // Direct path selection - no fallbacks
    final logoPath = size == LogoSize.small
        ? org.smallLogoAssetPath
        : org.largeLogoAssetPath;

    // Fail loudly if asset not found
    return Image.asset(
      logoPath,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
    );
  }
}
