import 'package:flutter/material.dart';

/// Environment types for the application.
enum Environment { staging, production }

/// Configuration for environment indicator chip.
class EnvironmentChipConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const EnvironmentChipConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

/// Pure function: Returns environment chip configuration based on environment string.
///
/// Defaults to staging for safety (shows warning if unknown environment).
EnvironmentChipConfig getEnvironmentChipConfig(String environment) {
  switch (environment.toLowerCase()) {
    case 'production':
      return const EnvironmentChipConfig(
        label: 'PROD',
        backgroundColor: Color(0xFF2E7D32), // Material green 800
        textColor: Colors.white,
      );
    case 'staging':
    default:
      return const EnvironmentChipConfig(
        label: 'STAGING - Changes will only be temporary',
        backgroundColor: Color(0xFFC62828), // Material red 800
        textColor: Colors.white,
      );
  }
}
