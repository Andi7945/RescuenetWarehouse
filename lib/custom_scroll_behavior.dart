import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag
// Needed for web (scrolling with mouse)
class CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        // The VoiceAccess sends pointer events with unknown type when scrolling
        // scrollables.
        PointerDeviceKind.unknown,
        PointerDeviceKind.mouse,
        // etc.
      };
}
