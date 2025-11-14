import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/features/printing/domain/priority_badge_config.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';

void main() {
  group('PriorityBadgeConfig.getShapeForDestination', () {
    test('returns shape from ModuleDestination when set', () {
      final dest = ModuleDestination(
        id: '1',
        name: 'Water',
        badgeShape: PriorityBadgeShape.star,
      );

      final result = PriorityBadgeConfig.getShapeForDestination(
        moduleDestination: dest,
      );

      expect(result, PriorityBadgeShape.star);
    });

    test('falls back to name mapping when badgeShape is null', () {
      final dest = ModuleDestination(
        id: '1',
        name: 'Water',
        badgeShape: null,
      );

      final result = PriorityBadgeConfig.getShapeForDestination(
        moduleDestination: dest,
      );

      expect(result, PriorityBadgeShape.circle); // Water maps to circle
    });

    test('returns circle default when no match', () {
      final result = PriorityBadgeConfig.getShapeForDestination(
        destinationName: 'Unknown Destination',
      );

      expect(result, PriorityBadgeShape.circle);
    });
  });
}
