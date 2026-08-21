import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/models/item.dart';
import 'package:rescuenet_warehouse/models/sign.dart';
import 'package:rescuenet_warehouse/pdf/print_sorting.dart';

Item _item({
  required String id,
  String? name,
  double weight = 0,
  bool coldChain = false,
  List<Sign> signs = const [],
}) => Item(
  id: id,
  name: name ?? id,
  rescueNetId: 1,
  totalAmount: 1,
  weight: weight,
  isColdChain: coldChain,
  signs: signs,
);

const _dangerSign = Sign(id: '5', unNumber: 'UN1234');

/// Guards against the old bug where a sign with id "2" was excluded from the
/// dangerous goods check.
const _signWithIdTwo = Sign(id: '2');

void main() {
  group('item classification', () {
    test('any sign marks an item as dangerous goods', () {
      expect(isDangerousGoodsItem(_item(id: 'a', signs: [_dangerSign])), isTrue);
      expect(isDangerousGoodsItem(_item(id: 'b')), isFalse);
      expect(
        isDangerousGoodsItem(_item(id: 'c', signs: [_signWithIdTwo])),
        isTrue,
      );
    });

    test('cold chain comes from the isColdChain flag only', () {
      expect(isColdChainItem(_item(id: 'a', coldChain: true)), isTrue);
      expect(isColdChainItem(_item(id: 'b', signs: [_dangerSign])), isFalse);
      expect(isColdChainItem(_item(id: 'c')), isFalse);
    });

    test('dangerous goods outrank cold chain', () {
      final both = _item(id: 'both', coldChain: true, signs: [_dangerSign]);
      final cold = _item(id: 'cold', coldChain: true);
      final plain = _item(id: 'plain');

      expect(packingItemRank(both), lessThan(packingItemRank(cold)));
      expect(packingItemRank(cold), lessThan(packingItemRank(plain)));
    });
  });

  group('sortItemsForPackingList', () {
    test('dangerous goods first, then cold chain, then heaviest', () {
      final normalLight = _item(id: 'normal-light', weight: 1);
      final normalHeavy = _item(id: 'normal-heavy', weight: 20);
      final cold = _item(id: 'cold', weight: 2, coldChain: true);
      final danger = _item(id: 'danger', weight: 0.5, signs: [_dangerSign]);

      final sorted = sortItemsForPackingList({
        normalLight: 1,
        cold: 1,
        normalHeavy: 1,
        danger: 1,
      });

      expect(sorted.map((e) => e.key.id).toList(), [
        'danger',
        'cold',
        'normal-heavy',
        'normal-light',
      ]);
    });

    test('weight comparison uses total weight (weight * amount)', () {
      final lightMany = _item(id: 'light-many', weight: 1);
      final heavyOne = _item(id: 'heavy-one', weight: 5);

      final sorted = sortItemsForPackingList({lightMany: 10, heavyOne: 1});

      expect(sorted.first.key.id, 'light-many');
    });

    test('equal weights fall back to name', () {
      final b = _item(id: 'b', name: 'Bandages', weight: 1);
      final a = _item(id: 'a', name: 'Axe', weight: 1);

      final sorted = sortItemsForPackingList({b: 1, a: 1});

      expect(sorted.map((e) => e.key.id).toList(), ['a', 'b']);
    });
  });

  group('compareContainersForSummary', () {
    int compare(
      (int, String, int) a,
      (int, String, int) b,
    ) => compareContainersForSummary(
      aPriority: a.$1,
      aDestination: a.$2,
      aNumber: a.$3,
      bPriority: b.$1,
      bDestination: b.$2,
      bNumber: b.$3,
    );

    test('sorts by priority first', () {
      expect(compare((1, 'Zulu', 99), (2, 'Alpha', 1)), lessThan(0));
    });

    test('groups by destination within a priority', () {
      expect(compare((1, 'Alpha', 99), (1, 'Water', 1)), lessThan(0));
    });

    test('sorts by container number within a destination', () {
      expect(compare((1, 'Water', 2), (1, 'Water', 10)), lessThan(0));
    });

    test('containers without destination go last within priority', () {
      expect(compare((1, '', 1), (1, 'Water', 99)), greaterThan(0));
    });

    test('unprioritised destinations sort after priorities 1-4', () {
      for (final priority in [1, 2, 3, 4]) {
        expect(
          compare((priority, 'Zulu', 99), (unprioritisedRank, 'Alpha', 1)),
          lessThan(0),
        );
      }
    });

    test('a container without destination sorts after all with one', () {
      final containers = [
        (unprioritisedRank, '', 1),
        (unprioritisedRank, 'Water', 7),
        (1, 'Office', 3),
      ];

      final sorted = [...containers]..sort(compare);

      expect(sorted.last, (unprioritisedRank, '', 1));
    });

    test('full ordering', () {
      final containers = [
        (2, 'Water', 5),
        (1, 'Water', 8),
        (1, 'Water', 3),
        (1, 'Base camp', 9),
        (1, '', 1),
        (4, 'Medical', 2),
      ];

      final sorted = [...containers]..sort(compare);

      expect(sorted, [
        (1, 'Base camp', 9),
        (1, 'Water', 3),
        (1, 'Water', 8),
        (1, '', 1),
        (2, 'Water', 5),
        (4, 'Medical', 2),
      ]);
    });
  });
}
