import 'package:equatable/equatable.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/models/log_entry.dart';
import 'package:rescuenet_warehouse/models/log_entry_summed.dart';

/// Aggregates daily log entries by item and container, summing counts and tracking users.
///
/// This pure function groups log entries by item ID and container ID, then sums
/// the counts and collects all unique users who performed the operations.
///
/// Used to create summary views of work logs showing net changes per item per container.
List<LogEntrySummed> sumDailyChanges(Iterable<LogEntry> entries) {
  var sum = entries
      .groupBy((p0) => _ItemAndContainer(p0.itemId, p0.containerId))
      .mapValues(
        (value) => value.fold(
          _CountAndUser({}, 0),
          (previousValue, element) => _CountAndUser(
            previousValue.user..add(element.user),
            previousValue.count + element.count,
          ),
        ),
      );

  var entr = sum.entries.map(
    (e) => LogEntrySummed(
      e.key.itemId,
      e.key.containerId,
      e.value.count,
      e.value.user.join(","),
    ),
  );

  return entr.toList();
}

/// Internal helper class to group log entries by item and container.
class _ItemAndContainer extends Equatable {
  final String itemId;
  final String containerId;

  _ItemAndContainer(this.itemId, this.containerId);

  @override
  List<Object> get props => [itemId, containerId];
}

/// Internal helper class to accumulate counts and users during aggregation.
class _CountAndUser extends Equatable {
  final Set<String> user;
  final int count;

  _CountAndUser(this.user, this.count);

  @override
  List<Object> get props => [user, count];
}
