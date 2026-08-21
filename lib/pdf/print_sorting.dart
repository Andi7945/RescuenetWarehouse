/// Pure sorting functions used by the PDF mappers.
///
/// Two different orderings are required:
///
/// **Packing list (items inside one container)**
/// 1. Dangerous goods items first
/// 2. Then cold chain items
/// 3. Then by total weight (heaviest first)
/// 4. Finally by name (stable, human readable tie breaker)
///
/// **Summary list (all containers in a row)**
/// 1. By module destination priority (1 -> 4, then [unprioritisedRank])
/// 2. Then grouped by destination name (alphabetical)
/// 3. Then by container number
library;

import '../models/item.dart';

/// Priority used for containers whose destination has no configured priority,
/// or which have no destination at all.
///
/// Sorts after every real priority (1..4) and is rendered verbatim on labels
/// as "Prio 99" with no badge colour, so unconfigured destinations are
/// visibly unconfigured rather than silently plausible.
const int unprioritisedRank = 99;

/// An item counts as dangerous goods if it carries at least one sign.
///
/// Signs are dangerous-goods placards (UN number, danger type, proper shipping
/// name, transport weight limits) - see [Sign]. Cold chain is *not* a sign, it
/// is the separate [Item.isColdChain] flag.
bool isDangerousGoodsItem(Item item) => item.signs.isNotEmpty;

/// An item is cold chain if it is flagged as such.
bool isColdChainItem(Item item) => item.isColdChain;

/// Sort rank for packing lists: lower comes first.
int packingItemRank(Item item) {
  if (isDangerousGoodsItem(item)) return 0;
  if (isColdChainItem(item)) return 1;
  return 2;
}

/// Total weight of an item line inside a container (single weight * amount).
double _totalWeight(MapEntry<Item, int> entry) =>
    entry.key.weight * entry.value;

/// Compare two item lines of a packing list.
int comparePackingItems(MapEntry<Item, int> a, MapEntry<Item, int> b) {
  final byRank = packingItemRank(a.key).compareTo(packingItemRank(b.key));
  if (byRank != 0) return byRank;

  // Heaviest first
  final byWeight = _totalWeight(b).compareTo(_totalWeight(a));
  if (byWeight != 0) return byWeight;

  return (a.key.name ?? "").toLowerCase().compareTo(
    (b.key.name ?? "").toLowerCase(),
  );
}

/// Returns the item lines of a container in packing list order.
List<MapEntry<Item, int>> sortItemsForPackingList(Map<Item, int> items) =>
    items.entries.toList()..sort(comparePackingItems);

/// Compare two containers for the summary list / print order.
///
/// [priority] is the module destination priority (1 = highest).
/// Containers without a destination are sorted last.
int compareContainersForSummary({
  required int aPriority,
  required String aDestination,
  required int aNumber,
  required int bPriority,
  required String bDestination,
  required int bNumber,
}) {
  final byPriority = aPriority.compareTo(bPriority);
  if (byPriority != 0) return byPriority;

  // Containers without destination go last within the same priority
  final aHas = aDestination.trim().isNotEmpty;
  final bHas = bDestination.trim().isNotEmpty;
  if (aHas != bHas) return aHas ? -1 : 1;

  final byDestination = aDestination.toLowerCase().compareTo(
    bDestination.toLowerCase(),
  );
  if (byDestination != 0) return byDestination;

  return aNumber.compareTo(bNumber);
}
