# Fine-Grained Reactivity: Containers Repository

## Objective
Eliminate excessive widget rebuilds caused by collection-level container listeners. Currently, when ANY container changes (name, status, location), ALL widgets watching containers rebuild. After this refactor, only widgets watching the specific changed container will rebuild.

## Expected Impact
- **Current:** Update Container #5 → ALL container views rebuild
- **Target:** Update Container #5 → ONLY widgets displaying Container #5 rebuild
- **Estimated rebuild reduction:** 65-80%

## Priority: MEDIUM
Containers are moderately updated (status flags, locations, metadata) and displayed in grids, detail views, and assignment interfaces.

---

## Step 1: Write Phase 1 Tests (Repository Stream Efficiency)

**Estimated Time:** 1.5 hours

### 1.1 Create Test File

**File:** `test/repositories/container_repository_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/repositories/impl/mock/mock_container_repository.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ContainerRepository Rebuild Efficiency', () {
    late MockContainerRepository repo;

    setUp(() {
      repo = MockContainerRepository();
      repo.clearContainers();
    });

    tearDown(() {
      repo.dispose();
    });

    group('Baseline (Current Behavior)', () {
      test('watchContainers() emits entire collection on any change', () async {
        final container1 = createTestContainer(id: 'container-1', name: 'Container 1');
        final container2 = createTestContainer(id: 'container-2', name: 'Container 2');

        await repo.upsertContainer(container1);
        await repo.upsertContainer(container2);

        int emissionCount = 0;
        final subscription = repo.watchContainers().listen((_) {
          emissionCount++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        emissionCount = 0;

        await repo.upsertContainer(container1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(emissionCount, greaterThan(0));

        subscription.cancel();
      });
    });

    group('Fine-Grained (Target Behavior)', () {
      test('watchContainer() emits only when specific container changes', () async {
        final container1 = createTestContainer(id: 'container-1');
        final container2 = createTestContainer(id: 'container-2');

        await repo.upsertContainer(container1);
        await repo.upsertContainer(container2);

        int container1Emissions = 0;
        final subscription = repo.watchContainer('container-1').listen((_) {
          container1Emissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        container1Emissions = 0;

        // Update different container
        await repo.upsertContainer(container2.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(container1Emissions, equals(0));

        // Update tracked container
        await repo.upsertContainer(container1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(container1Emissions, equals(1));

        subscription.cancel();
      });

      test('watchContainersByLocation() emits only when location changes', () async {
        final warehouseA1 = createTestContainer(
          id: 'container-1',
          currentLocationId: 'warehouse-a',
        );
        final warehouseA2 = createTestContainer(
          id: 'container-2',
          currentLocationId: 'warehouse-a',
        );
        final warehouseB = createTestContainer(
          id: 'container-3',
          currentLocationId: 'warehouse-b',
        );

        await repo.upsertContainer(warehouseA1);
        await repo.upsertContainer(warehouseA2);
        await repo.upsertContainer(warehouseB);

        int warehouseAEmissions = 0;
        final subscription = repo
            .watchContainersByLocation('warehouse-a')
            .listen((_) {
          warehouseAEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        warehouseAEmissions = 0;

        // Update container in different location
        await repo.upsertContainer(warehouseB.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(warehouseAEmissions, equals(0));

        // Update container in tracked location
        await repo.upsertContainer(warehouseA1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(warehouseAEmissions, equals(1));

        subscription.cancel();
      });

      test('watchContainersByType() emits only when type changes', () async {
        final euroBox1 = createTestContainer(
          id: 'container-1',
          typeId: 'euro-box',
        );
        final euroBox2 = createTestContainer(
          id: 'container-2',
          typeId: 'euro-box',
        );
        final palette = createTestContainer(
          id: 'container-3',
          typeId: 'palette',
        );

        await repo.upsertContainer(euroBox1);
        await repo.upsertContainer(euroBox2);
        await repo.upsertContainer(palette);

        int euroBoxEmissions = 0;
        final subscription = repo
            .watchContainersByType('euro-box')
            .listen((_) {
          euroBoxEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        euroBoxEmissions = 0;

        // Update container with different type
        await repo.upsertContainer(palette.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(euroBoxEmissions, equals(0));

        // Update container with tracked type
        await repo.upsertContainer(euroBox1.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(euroBoxEmissions, equals(1));

        subscription.cancel();
      });

      test('watchContainersByReadyStatus() emits only when ready status changes', () async {
        final ready = createTestContainer(id: 'container-1', isReady: true);
        final notReady = createTestContainer(id: 'container-2', isReady: false);

        await repo.upsertContainer(ready);
        await repo.upsertContainer(notReady);

        int readyEmissions = 0;
        final subscription = repo
            .watchContainersByReadyStatus(true)
            .listen((_) {
          readyEmissions++;
        });

        await Future.delayed(Duration(milliseconds: 50));
        readyEmissions = 0;

        // Update not-ready container
        await repo.upsertContainer(notReady.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(readyEmissions, equals(0));

        // Update ready container
        await repo.upsertContainer(ready.copyWith(name: 'Updated'));
        await Future.delayed(Duration(milliseconds: 50));

        expect(readyEmissions, equals(1));

        subscription.cancel();
      });
    });
  });
}
```

### 1.2 Run Tests (Should FAIL)

```bash
flutter test test/repositories/container_repository_rebuild_test.dart
```

---

## Step 2: Update Repository Interface

**Estimated Time:** 30 minutes

### 2.1 Update Container Repository Interface

**File:** `lib/repositories/container_repository.dart`

Add these methods:

```dart
abstract class ContainerRepository {
  // Existing methods...
  Stream<List<ContainerDao>> watchContainers();
  Future<ContainerDao?> getContainer(String id);
  Future<void> createContainer(ContainerDao container);
  Future<void> updateContainer(ContainerDao container);
  Future<void> upsertContainer(ContainerDao container);
  Future<void> deleteContainer(String id);
  Future<void> batchUpdateContainers(List<ContainerDao> containers);
  Future<List<ContainerDao>> getContainersByLocation(String locationId);
  Future<List<ContainerDao>> getContainersByType(String containerTypeId);

  // NEW: Fine-grained stream methods

  /// Watch a single container by ID.
  /// Emits only when this specific container changes.
  Stream<ContainerDao?> watchContainer(String containerId);

  /// Watch containers at a specific location.
  /// Emits only when containers at this location change.
  Stream<List<ContainerDao>> watchContainersByLocation(String locationId);

  /// Watch containers of a specific type.
  /// Emits only when containers of this type change.
  Stream<List<ContainerDao>> watchContainersByType(String containerTypeId);

  /// Watch containers by ready status.
  /// Emits only when containers with this status change.
  Stream<List<ContainerDao>> watchContainersByReadyStatus(bool isReady);

  /// Watch containers by deployment status.
  /// Emits only when containers with this status change.
  Stream<List<ContainerDao>> watchContainersByDeployStatus(bool toDeploy);
}
```

---

## Step 3: Implement Firebase Repository

**Estimated Time:** 2 hours

### 3.1 Update Firebase Container Repository

**File:** `lib/repositories/impl/firebase/firebase_container_repository.dart`

Add implementations:

```dart
@override
Stream<ContainerDao?> watchContainer(String containerId) {
  return containersCollection.doc(containerId).snapshots().map(
        (snapshot) => snapshot.exists ? snapshot.data() : null,
      );
}

@override
Stream<List<ContainerDao>> watchContainersByLocation(String locationId) {
  return containersCollection
      .where('currentLocationId', isEqualTo: locationId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<List<ContainerDao>> watchContainersByType(String containerTypeId) {
  return containersCollection
      .where('typeId', isEqualTo: containerTypeId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<List<ContainerDao>> watchContainersByReadyStatus(bool isReady) {
  return containersCollection
      .where('isReady', isEqualTo: isReady)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}

@override
Stream<List<ContainerDao>> watchContainersByDeployStatus(bool toDeploy) {
  return containersCollection
      .where('toDeploy', isEqualTo: toDeploy)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
}
```

---

## Step 4: Implement Mock Repository

**Estimated Time:** 1 hour

### 4.1 Update Mock Container Repository

**File:** `lib/repositories/impl/mock/mock_container_repository.dart`

Add implementations:

```dart
@override
Stream<ContainerDao?> watchContainer(String containerId) {
  return _containersController.stream.map(
    (allContainers) {
      try {
        return allContainers.firstWhere((c) => c.id == containerId);
      } catch (e) {
        return null;
      }
    },
  );
}

@override
Stream<List<ContainerDao>> watchContainersByLocation(String locationId) {
  return _containersController.stream.map(
    (allContainers) => allContainers
        .where((c) => c.currentLocationId == locationId)
        .toList(),
  );
}

@override
Stream<List<ContainerDao>> watchContainersByType(String containerTypeId) {
  return _containersController.stream.map(
    (allContainers) =>
        allContainers.where((c) => c.typeId == containerTypeId).toList(),
  );
}

@override
Stream<List<ContainerDao>> watchContainersByReadyStatus(bool isReady) {
  return _containersController.stream.map(
    (allContainers) =>
        allContainers.where((c) => c.isReady == isReady).toList(),
  );
}

@override
Stream<List<ContainerDao>> watchContainersByDeployStatus(bool toDeploy) {
  return _containersController.stream.map(
    (allContainers) =>
        allContainers.where((c) => c.toDeploy == toDeploy).toList(),
  );
}
```

### 4.2 Add clearContainers() and dispose() if missing

```dart
void clearContainers() {
  _containers.clear();
  _containersController.add([]);
}

void dispose() {
  _containersController.close();
}
```

---

## Step 5: Verify Phase 1 Tests Pass

**Estimated Time:** 30 minutes

```bash
flutter test test/repositories/container_repository_rebuild_test.dart
```

---

## Step 6: Write Phase 2 Tests (Provider Rebuild Efficiency)

**Estimated Time:** 2 hours

### 6.1 Create Provider Test File

**File:** `test/state/container_provider_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/container_by_id_notifier.dart';
import 'package:rescuenet_warehouse/state/containers_by_location_notifier.dart';
import 'package:rescuenet_warehouse/state/containers_by_type_notifier.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Container Provider Rebuild Efficiency', () {
    test('containerByIdProvider only rebuilds when specific container changes',
        () async {
      final container = createTestProviderContainer();

      final container1 = createTestContainer(id: 'container-1');
      final container2 = createTestContainer(id: 'container-2');

      final repo = container.read(containerRepositoryProvider);
      await repo.upsertContainer(container1);
      await repo.upsertContainer(container2);

      int container1Rebuilds = 0;
      container.listen(
        containerByIdProvider('container-1'),
        (previous, next) {
          container1Rebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      container1Rebuilds = 0;

      // Update different container
      await repo.upsertContainer(container2.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(container1Rebuilds, equals(0));

      // Update tracked container
      await repo.upsertContainer(container1.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(container1Rebuilds, equals(1));

      container.dispose();
    });

    test('containersByLocationProvider only rebuilds when location changes',
        () async {
      final container = createTestProviderContainer();

      final warehouseA = createTestContainer(
        id: 'container-1',
        currentLocationId: 'warehouse-a',
      );
      final warehouseB = createTestContainer(
        id: 'container-2',
        currentLocationId: 'warehouse-b',
      );

      final repo = container.read(containerRepositoryProvider);
      await repo.upsertContainer(warehouseA);
      await repo.upsertContainer(warehouseB);

      int warehouseARebuilds = 0;
      container.listen(
        containersByLocationProvider('warehouse-a'),
        (previous, next) {
          warehouseARebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      warehouseARebuilds = 0;

      // Update container in different location
      await repo.upsertContainer(warehouseB.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(warehouseARebuilds, equals(0));

      container.dispose();
    });
  });
}
```

---

## Step 7: Create Family Providers

**Estimated Time:** 1.5 hours

### 7.1 Create ContainerById Provider

**File:** `lib/state/container_by_id_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/container_dao.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';

part 'container_by_id_notifier.g.dart';

/// Watches a single container by ID.
/// Only rebuilds when THIS specific container changes.
///
/// Returns RescueContainer (expanded with type, location, destination).
///
/// Usage:
/// ```dart
/// final container = ref.watch(containerByIdProvider(containerId));
/// ```
@riverpod
class ContainerById extends _$ContainerById {
  @override
  Stream<RescueContainer?> build(String containerId) {
    final repository = ref.watch(containerRepositoryProvider);
    final containerTypesNotifier = ref.watch(containerTypesNotifierProvider.notifier);
    final moduleDestinationsNotifier = ref.watch(moduleDestinationsNotifierProvider.notifier);
    final currentLocationsNotifier = ref.watch(currentLocationsNotifierProvider.notifier);

    return repository.watchContainer(containerId).map((dao) {
      if (dao == null) return null;

      final type = containerTypesNotifier.find(dao.typeId);
      final dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
      final loc = currentLocationsNotifier.find(dao.currentLocationId);

      return RescueContainer.fromDao(dao, type, dest, loc);
    });
  }
}
```

### 7.2 Create ContainersByLocation Provider

**File:** `lib/state/containers_by_location_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';

part 'containers_by_location_notifier.g.dart';

/// Watches containers at a specific location.
/// Only rebuilds when containers at THIS location change.
///
/// Usage:
/// ```dart
/// final containers = ref.watch(containersByLocationProvider(locationId));
/// ```
@riverpod
class ContainersByLocation extends _$ContainersByLocation {
  @override
  Stream<List<RescueContainer>> build(String locationId) {
    final repository = ref.watch(containerRepositoryProvider);
    final containerTypesNotifier = ref.watch(containerTypesNotifierProvider.notifier);
    final moduleDestinationsNotifier = ref.watch(moduleDestinationsNotifierProvider.notifier);
    final currentLocationsNotifier = ref.watch(currentLocationsNotifierProvider.notifier);

    return repository.watchContainersByLocation(locationId).map((containers) {
      return containers.map((dao) {
        final type = containerTypesNotifier.find(dao.typeId);
        final dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
        final loc = currentLocationsNotifier.find(dao.currentLocationId);
        return RescueContainer.fromDao(dao, type, dest, loc);
      }).toList();
    });
  }
}
```

### 7.3 Create ContainersByType Provider

**File:** `lib/state/containers_by_type_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';

part 'containers_by_type_notifier.g.dart';

/// Watches containers of a specific type.
/// Only rebuilds when containers of THIS type change.
///
/// Usage:
/// ```dart
/// final euroBoxes = ref.watch(containersByTypeProvider('euro-box'));
/// ```
@riverpod
class ContainersByType extends _$ContainersByType {
  @override
  Stream<List<RescueContainer>> build(String containerTypeId) {
    final repository = ref.watch(containerRepositoryProvider);
    final containerTypesNotifier = ref.watch(containerTypesNotifierProvider.notifier);
    final moduleDestinationsNotifier = ref.watch(moduleDestinationsNotifierProvider.notifier);
    final currentLocationsNotifier = ref.watch(currentLocationsNotifierProvider.notifier);

    return repository.watchContainersByType(containerTypeId).map((containers) {
      return containers.map((dao) {
        final type = containerTypesNotifier.find(dao.typeId);
        final dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
        final loc = currentLocationsNotifier.find(dao.currentLocationId);
        return RescueContainer.fromDao(dao, type, dest, loc);
      }).toList();
    });
  }
}
```

### 7.4 Create ContainersByReadyStatus Provider

**File:** `lib/state/containers_by_ready_status_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
import 'package:rescuenet_warehouse/state/container_types_notifier.dart';
import 'package:rescuenet_warehouse/state/module_destinations_notifier.dart';
import 'package:rescuenet_warehouse/state/current_locations_notifier.dart';

part 'containers_by_ready_status_notifier.g.dart';

/// Watches containers by ready status.
/// Only rebuilds when containers with THIS status change.
///
/// Usage:
/// ```dart
/// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
/// ```
@riverpod
class ContainersByReadyStatus extends _$ContainersByReadyStatus {
  @override
  Stream<List<RescueContainer>> build(bool isReady) {
    final repository = ref.watch(containerRepositoryProvider);
    final containerTypesNotifier = ref.watch(containerTypesNotifierProvider.notifier);
    final moduleDestinationsNotifier = ref.watch(moduleDestinationsNotifierProvider.notifier);
    final currentLocationsNotifier = ref.watch(currentLocationsNotifierProvider.notifier);

    return repository.watchContainersByReadyStatus(isReady).map((containers) {
      return containers.map((dao) {
        final type = containerTypesNotifier.find(dao.typeId);
        final dest = moduleDestinationsNotifier.find(dao.moduleDestinationId);
        final loc = currentLocationsNotifier.find(dao.currentLocationId);
        return RescueContainer.fromDao(dao, type, dest, loc);
      }).toList();
    });
  }
}
```

---

## Step 8: Run Code Generation

**Estimated Time:** 2 minutes

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 9: Verify Phase 2 Tests Pass

**Estimated Time:** 30 minutes

```bash
flutter test test/state/container_provider_rebuild_test.dart
```

---

## Step 10: Migrate Widgets

**Estimated Time:** 2 hours

### 10.1 Find Widgets to Migrate

```bash
grep -r "ref.watch(allContainersAsyncProvider)" lib/ui/ lib/features/
```

### 10.2 Migration Patterns

#### Pattern 1: Single Container Display

**Before:**
```dart
final allContainers = ref.watch(allContainersAsyncProvider);
final container = allContainers.valueOrNull?.firstWhere((c) => c.id == containerId);
```

**After:**
```dart
final container = ref.watch(containerByIdProvider(containerId));
```

#### Pattern 2: Location Filtering

**Before:**
```dart
final allContainers = ref.watch(allContainersAsyncProvider);
final warehouseContainers = allContainers.valueOrNull
    ?.where((c) => c.currentLocationId == locationId)
    .toList();
```

**After:**
```dart
final warehouseContainers = ref.watch(
  containersByLocationProvider(locationId),
);
```

### 10.3 Key Files to Update

1. **ContainerWithContentPage** (if displays single container)
   - Use `containerByIdProvider(containerId)`

2. **Container Edit Views**
   - Use `containerByIdProvider(containerId)`

3. **Location-Based Filters**
   - Use `containersByLocationProvider(locationId)`

4. **Type-Based Filters**
   - Use `containersByTypeProvider(typeId)`

### 10.4 Keep Collection Provider For

- Container grid showing all containers
- Dashboard overview
- Export/reports
- Full container list views

---

## Step 11: Manual Testing

**Estimated Time:** 30 minutes

1. Open container detail view
2. Open container list view
3. Update container details
4. Verify only detail view updates, not list

---

## Step 12: Integration Test

**Estimated Time:** 1 hour

**File:** `test/state/container_integration_rebuild_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/container_by_id_notifier.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Container Integration - Multi-Provider Rebuild', () {
    test('Updating Container A does not rebuild Container B watchers', () async {
      final container = createTestProviderContainer();

      final containerA = createTestContainer(id: 'container-a');
      final containerB = createTestContainer(id: 'container-b');

      final repo = container.read(containerRepositoryProvider);
      await repo.upsertContainer(containerA);
      await repo.upsertContainer(containerB);

      int containerBRebuilds = 0;
      container.listen(
        containerByIdProvider('container-b'),
        (previous, next) {
          containerBRebuilds++;
        },
      );

      await Future.delayed(Duration(milliseconds: 100));
      containerBRebuilds = 0;

      await repo.upsertContainer(containerA.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      expect(containerBRebuilds, equals(0));

      container.dispose();
    });
  });
}
```

---

## Success Criteria

- ✅ All Phase 1 tests pass
- ✅ All Phase 2 tests pass
- ✅ Integration test passes
- ✅ Manual testing shows isolated updates
- ✅ Container detail pages only update when their container changes

---

## Special Considerations

### RescueContainer Expansion

Containers require expansion from `ContainerDao` → `RescueContainer` with type, location, destination lookups. Family providers handle this automatically, maintaining the same pattern as `allContainersAsyncProvider`.

### Status Filters

The app uses `isReady` and `toDeploy` flags extensively. Fine-grained providers for these will significantly improve filter performance.

---

## Notes

- Container providers depend on type/location/destination notifiers
- These dependencies are lightweight (metadata rarely changes)
- Focus migration on container detail views and filtered lists
- Keep collection provider for full container grids
