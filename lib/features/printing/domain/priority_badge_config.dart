import 'package:rescuenet_warehouse/models/module_destination.dart';

/// Configuration for priority badge shapes based on destination names.
///
/// This maps destination names to specific badge shapes, following the
/// pattern observed in the RescueNet V2 label design.

enum PriorityBadgeShape {
  circle,
  rectangle,
  triangle,
  diamond,
  star,
  heart,
  cross,
}

class PriorityBadgeConfig {
  /// Maps destination names to their appropriate badge shapes.
  ///
  /// Based on analysis of RN_box_label_V2_example.pdf:
  /// - Priority 1 (Red): Circle or Rectangle
  /// - Priority 2 (Yellow): Triangle or Diamond
  /// - Priority 3 (Green): Star
  /// - Priority 4 (Blue): Heart or Cross
  static const Map<String, PriorityBadgeShape> destinationShapeMap = {
    // Priority 1 - Red shapes
    'Water': PriorityBadgeShape.circle,
    'Water treatment': PriorityBadgeShape.circle,
    'Office': PriorityBadgeShape.rectangle,

    // Priority 2 - Yellow shapes
    'Storage': PriorityBadgeShape.triangle,
    'Staff': PriorityBadgeShape.diamond,
    'Staff area': PriorityBadgeShape.diamond,

    // Priority 3 - Green shapes
    'Waste': PriorityBadgeShape.star,

    // Priority 4 - Blue shapes
    'Mobile Clinic': PriorityBadgeShape.heart,
    'Medical storage': PriorityBadgeShape.cross,
    'Medical': PriorityBadgeShape.cross,
  };

  /// Pure function: Returns badge shape for a destination
  /// Priority: 1) ModuleDestination.badgeShape, 2) Name mapping, 3) Circle default
  static PriorityBadgeShape getShapeForDestination({
    ModuleDestination? moduleDestination,
    String? destinationName,
    // Legacy parameters for backward compatibility
    String? destination,
    int? priority,  // Kept for backward compat, but no longer used in logic
  }) {
    // 1. Check if ModuleDestination has explicit shape configured
    if (moduleDestination?.badgeShape != null) {
      return moduleDestination!.badgeShape!;
    }

    // 2. Fall back to legacy name-based mapping
    // Support both old (destination) and new (destinationName) parameter names
    final name = destinationName ?? moduleDestination?.name ?? destination;
    if (name != null && destinationShapeMap.containsKey(name)) {
      return destinationShapeMap[name]!;
    }

    // 3. Default to circle
    return PriorityBadgeShape.circle;
  }

  /// Returns the asset path for a given badge shape.
  static String getAssetPath(PriorityBadgeShape shape) {
    switch (shape) {
      case PriorityBadgeShape.circle:
        return 'assets/priority_badges/prio1_circle.svg';
      case PriorityBadgeShape.rectangle:
        return 'assets/priority_badges/prio1_rectangle.svg';
      case PriorityBadgeShape.triangle:
        return 'assets/priority_badges/prio2_triangle.svg';
      case PriorityBadgeShape.diamond:
        return 'assets/priority_badges/prio2_diamond.svg';
      case PriorityBadgeShape.star:
        return 'assets/priority_badges/prio3_star.svg';
      case PriorityBadgeShape.heart:
        return 'assets/priority_badges/prio4_heart.svg';
      case PriorityBadgeShape.cross:
        return 'assets/priority_badges/prio4_cross.svg';
    }
  }

  /// Returns the color for a given priority level.
  ///
  /// Note: Colors are baked into the SVG assets, but this method
  /// is provided for reference and potential programmatic use.
  static String getColorForPriority(int priority) {
    switch (priority) {
      case 1:
        return '#FF0000'; // Red
      case 2:
        return '#FFFF00'; // Yellow
      case 3:
        return '#00FF00'; // Green
      case 4:
        return '#0000FF'; // Blue (heart) or #00BFFF (cross)
      default:
        return '#FF0000'; // Safe fallback to red
    }
  }
}
