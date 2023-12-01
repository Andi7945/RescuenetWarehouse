import '../models/item.dart';

import 'package:intl/intl.dart';

calcValue(Map<Item, int> items) => items.entries.fold(
    0,
    (previousValue, itmWithCount) =>
        previousValue + itmWithCount.key.value * itmWithCount.value);

final DateFormat formatter = DateFormat('MMM yy');

nextExpirationDateFormatted(Map<Item, int> items) {
  var nextDate = nextExpirationDate(items);
  return nextDate != null ? formatter.format(nextDate) : "";
}

DateTime? nextExpirationDate(Map<Item, int> items) =>
    _calcNextExpirationDate(items.keys.expand((e) => e.expiringDates));

DateTime? nextExpirationDateSingle(MapEntry<Item, int> item) =>
    _calcNextExpirationDate(item.key.expiringDates);

DateTime? _calcNextExpirationDate(Iterable<DateTime> dates) {
  var starTrek = DateTime.utc(9999);

  var nextDate = dates.fold(starTrek, (previousValue, element) {
    if (element.isBefore(previousValue)) {
      return element;
    }
    return previousValue;
  });

  if (nextDate == starTrek) {
    return null;
  }
  return nextDate;
}
