import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/features/printing/domain/container_refresh.dart';
import 'package:rescuenet_warehouse/models/container_type.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/models/sequential_build.dart';

void main() {
  const staleType = ContainerType(
    id: 't1',
    name: 'Old type',
    emptyWeight: 1,
    measurements: '1x1x1',
  );
  const freshType = ContainerType(
    id: 't1',
    name: 'New type',
    emptyWeight: 1,
    measurements: '1x1x1',
  );

  const staleDestination = ModuleDestination(
    id: 'd1',
    name: 'Old dest',
    priority: 3,
  );
  const freshDestination = ModuleDestination(
    id: 'd1',
    name: 'New dest',
    priority: 1,
  );

  const staleLocation = CurrentLocation(id: 'l1', name: 'Old location');
  const freshLocation = CurrentLocation(id: 'l1', name: 'New location');

  RescueContainer container() => const RescueContainer(
    id: 'c1',
    number: 42,
    name: 'Container',
    type: staleType,
    sequentialBuild: SequentialBuild.preBuild,
    moduleDestination: staleDestination,
    currentLocation: staleLocation,
    isReady: true,
    toDeploy: false,
  );

  group('refreshContainer', () {
    test('resolves updated type, destination and location by id', () {
      final result = refreshContainer(
        container(),
        types: [freshType],
        destinations: [freshDestination],
        locations: [freshLocation],
      );

      expect(result.type, freshType);
      expect(result.moduleDestination, freshDestination);
      expect(result.moduleDestination?.priority, 1);
      expect(result.currentLocation, freshLocation);
    });

    test('keeps existing objects when the lists are empty', () {
      // Data-loss guard: the backing notifiers return [] on first build and
      // populate asynchronously. A naive re-resolve would null these out and
      // wipe the destination off the PDF.
      final result = refreshContainer(
        container(),
        types: [],
        destinations: [],
        locations: [],
      );

      expect(result.type, staleType);
      expect(result.moduleDestination, staleDestination);
      expect(result.currentLocation, staleLocation);
    });

    test('keeps existing objects when ids are not found', () {
      final result = refreshContainer(
        container(),
        types: [
          const ContainerType(
            id: 'other',
            name: 'Other',
            emptyWeight: 1,
            measurements: '1x1x1',
          ),
        ],
        destinations: [const ModuleDestination(id: 'other', name: 'Other')],
        locations: [const CurrentLocation(id: 'other', name: 'Other')],
      );

      expect(result.type, staleType);
      expect(result.moduleDestination, staleDestination);
      expect(result.currentLocation, staleLocation);
    });

    test('leaves non-denormalised fields untouched', () {
      final result = refreshContainer(
        container(),
        types: [freshType],
        destinations: [freshDestination],
        locations: [freshLocation],
      );

      expect(result.id, 'c1');
      expect(result.number, 42);
      expect(result.name, 'Container');
      expect(result.isReady, isTrue);
      expect(result.toDeploy, isFalse);
    });

    test('tolerates a container with no type, destination or location', () {
      const bare = RescueContainer(
        id: 'c2',
        number: 1,
        name: 'Bare',
        sequentialBuild: SequentialBuild.preBuild,
        isReady: false,
        toDeploy: false,
      );

      final result = refreshContainer(
        bare,
        types: [freshType],
        destinations: [freshDestination],
        locations: [freshLocation],
      );

      expect(result.type, isNull);
      expect(result.moduleDestination, isNull);
      expect(result.currentLocation, isNull);
    });
  });
}
