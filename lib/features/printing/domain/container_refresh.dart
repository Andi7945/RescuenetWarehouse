import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/container_type.dart';
import 'package:rescuenet_warehouse/models/current_location.dart';
import 'package:rescuenet_warehouse/models/module_destination.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

/// Re-resolves the denormalised type / destination / location on [container]
/// against the given current lists.
///
/// [RescueContainer] is denormalised: Firestore stores only ids, which are
/// resolved to full objects inside the container provider bodies. Those bodies
/// use `ref.watch(x.notifier)`, which does not re-run when the notifier's state
/// changes, so a renamed container type or an edited module destination priority
/// stays stale on the container until a container document changes or the app
/// reloads. Calling this at the PDF export boundary makes the printed document
/// reflect the current values.
///
/// Falls back to the existing object when a lookup fails, so a not-yet-loaded
/// list degrades to stale data rather than deleting it. This matters because
/// the backing notifiers populate asynchronously and return `[]` on first build.
RescueContainer refreshContainer(
  RescueContainer container, {
  required List<ContainerType> types,
  required List<ModuleDestination> destinations,
  required List<CurrentLocation> locations,
}) => container.copyWith(
  type: types.firstWhereOrNull((t) => t.id == container.type?.id) ?? container.type,
  moduleDestination:
      destinations.firstWhereOrNull(
        (d) => d.id == container.moduleDestination?.id,
      ) ??
      container.moduleDestination,
  currentLocation:
      locations.firstWhereOrNull(
        (l) => l.id == container.currentLocation?.id,
      ) ??
      container.currentLocation,
);
