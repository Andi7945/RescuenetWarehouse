// TEMPORARY BACKWARD COMPATIBILITY FILE
// This file maintains compatibility with the existing app while Phase 1 is implemented.
// This file will be removed in Phase 2 when main.dart is updated to use the new config system.

import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options_rescuenet_production.dart';

/// Backward compatibility wrapper for the original DefaultFirebaseOptions class.
/// This delegates to the production configuration.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      RescuenetProductionFirebaseOptions.currentPlatform;
}
