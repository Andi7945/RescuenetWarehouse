import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/features/printing/domain/priority_badge_config.dart';

/// Dropdown selector for badge shapes with visual preview icons
class BadgeShapeSelector extends StatelessWidget {
  final PriorityBadgeShape? value;
  final ValueChanged<PriorityBadgeShape?> onChanged;
  final bool enabled;

  const BadgeShapeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PriorityBadgeShape>(
      value: value,
      isExpanded: true,
      hint: const Text('Select badge shape'),
      items: [
        // Clear selection option
        const DropdownMenuItem<PriorityBadgeShape>(
          value: null,
          child: Text('(Auto - from name)'),
        ),
        // All available shapes
        ...PriorityBadgeShape.values.map((shape) {
          return DropdownMenuItem<PriorityBadgeShape>(
            value: shape,
            child: Row(
              children: [
                _buildShapeIcon(shape),
                const SizedBox(width: 8),
                Text(_getShapeLabel(shape)),
              ],
            ),
          );
        }),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }

  /// Visual preview icon for each shape
  Widget _buildShapeIcon(PriorityBadgeShape shape) {
    final colorHex = PriorityBadgeConfig.getColorForPriority(
      _getPriorityForShape(shape),
    );
    final color = _hexToColor(colorHex);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        border: Border.all(color: color, width: 2),
        shape: shape == PriorityBadgeShape.circle
          ? BoxShape.circle
          : BoxShape.rectangle,
      ),
      child: Center(
        child: Icon(
          _getIconForShape(shape),
          size: 16,
          color: color,
        ),
      ),
    );
  }

  /// Convert hex color string to Color object
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) buffer.write('ff'); // Add alpha if missing
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Human-readable shape labels
  String _getShapeLabel(PriorityBadgeShape shape) {
    switch (shape) {
      case PriorityBadgeShape.circle:
        return 'Circle';
      case PriorityBadgeShape.rectangle:
        return 'Rectangle';
      case PriorityBadgeShape.triangle:
        return 'Triangle';
      case PriorityBadgeShape.diamond:
        return 'Diamond';
      case PriorityBadgeShape.star:
        return 'Star';
      case PriorityBadgeShape.heart:
        return 'Heart';
      case PriorityBadgeShape.cross:
        return 'Cross';
    }
  }

  /// Icon representation for each shape
  IconData _getIconForShape(PriorityBadgeShape shape) {
    switch (shape) {
      case PriorityBadgeShape.circle:
        return Icons.circle_outlined;
      case PriorityBadgeShape.rectangle:
        return Icons.rectangle_outlined;
      case PriorityBadgeShape.triangle:
        return Icons.change_history;
      case PriorityBadgeShape.diamond:
        return Icons.diamond_outlined;
      case PriorityBadgeShape.star:
        return Icons.star_outline;
      case PriorityBadgeShape.heart:
        return Icons.favorite_border;
      case PriorityBadgeShape.cross:
        return Icons.add_circle_outline;
    }
  }

  /// Get associated priority for color coding
  int _getPriorityForShape(PriorityBadgeShape shape) {
    // Map shapes to their typical priority (for color preview)
    switch (shape) {
      case PriorityBadgeShape.circle:
      case PriorityBadgeShape.rectangle:
        return 1; // Red
      case PriorityBadgeShape.triangle:
      case PriorityBadgeShape.diamond:
        return 2; // Yellow
      case PriorityBadgeShape.star:
        return 3; // Green
      case PriorityBadgeShape.heart:
      case PriorityBadgeShape.cross:
        return 4; // Blue
    }
  }
}
