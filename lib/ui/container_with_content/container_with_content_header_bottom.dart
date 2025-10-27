import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../models/operational_status.dart';
import '../../models/rescue_container.dart';
import '../../models/sign.dart';
import '../rescue_box_module_destination.dart';
import '../rescue_box_sequential_build.dart';
import '../sign_row.dart';

class ContainerWithContentHeaderBottom extends StatelessWidget {
  final RescueContainer container;
  final Map<Item, int> items;

  const ContainerWithContentHeaderBottom({
    super.key,
    required this.container,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    var availableWidth = 400;
    var neededWidth = _indicatorLength() + 8 + 108 + 108;

    if (availableWidth < neededWidth) {
      return _twoRowLayout();
    }
    return _singleRowLayout();
  }

  Widget _twoRowLayout() => Column(
    children: [
      SignRow(_signs(), _nextExpired(), _operationalStatus(), _isColdChain()),
      Container(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RescueBoxSequentialBuild(container), // width: 108
            Flexible(child: RescueBoxModuleDestination(container)),
          ],
        ),
      ),
    ],
  );

  Widget _singleRowLayout() => Container(
    padding: const EdgeInsets.all(4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RescueBoxSequentialBuild(container), // width: 108
        SignRow(_signs(), _nextExpired(), _operationalStatus(), _isColdChain()),
        RescueBoxModuleDestination(container), // maxWidth: 160
      ],
    ),
  );

  List<Sign> _signs() {
    return items.keys.expand((i) => i.signs).toList();
  }

  DateTime? _nextExpired() {
    var dates = items.keys.expand((element) => element.expiringDates).toList();
    if (dates.isEmpty) {
      return null;
    }
    dates.sort();
    return dates.first;
  }

  _operationalStatus() {
    var status = items.keys.map((e) => e.operationalStatus).toSet();
    if (status.contains(OperationalStatus.toBeReplaced)) {
      return OperationalStatus.toBeReplaced;
    }
    if (status.contains(OperationalStatus.needsRepair)) {
      return OperationalStatus.needsRepair;
    }
    return OperationalStatus.deployable;
  }

  bool _isColdChain() => items.keys.any((itm) => itm.isColdChain);

  int _indicatorLength() =>
      _signs().length * 40 +
      _expiredLength() +
      _coldChainLength() +
      8; // 8: padding of SignRow

  int _expiredLength() => _nextExpired() != null ? 40 : 0;

  int _coldChainLength() => _isColdChain() ? 40 : 0;
}
