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

  /// Gets the badge shape for a given destination and priority.
  ///
  /// If a specific mapping exists for the destination, it uses that.
  /// Otherwise, falls back to the default shape for the priority level.
  static PriorityBadgeShape getShapeForDestination({
    required String destination,
    required int priority,
  }) {
    // Try to find exact match first
    final shape = destinationShapeMap[destination];
    if (shape != null) {
      return shape;
    }

    // Fall back to default shape for priority level
    return _getDefaultShapeForPriority(priority);
  }

  /// Returns the default badge shape for each priority level.
  static PriorityBadgeShape _getDefaultShapeForPriority(int priority) {
    switch (priority) {
      case 1:
        return PriorityBadgeShape.circle;
      case 2:
        return PriorityBadgeShape.triangle;
      case 3:
        return PriorityBadgeShape.star;
      case 4:
        return PriorityBadgeShape.heart;
      default:
        return PriorityBadgeShape.circle; // Safe fallback
    }
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
