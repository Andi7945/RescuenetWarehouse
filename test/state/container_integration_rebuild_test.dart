import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/state/container_by_id_notifier.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';
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

      // Wait for initial state to settle
      await Future.delayed(Duration(milliseconds: 100));
      containerBRebuilds = 0;

      // Update container A
      await repo.upsertContainer(containerA.copyWith(name: 'Updated'));
      await Future.delayed(Duration(milliseconds: 100));

      // Verify container B watcher did not rebuild
      expect(containerBRebuilds, equals(0));

      container.dispose();
    });
  });
}
