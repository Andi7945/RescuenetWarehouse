import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescuenet_warehouse/db/item_data.dart';
import 'package:rescuenet_warehouse/db/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';

import '../models/item.dart';

part 'all_items_notifier.g.dart';

@riverpod
class AllItemsNotifier extends _$AllItemsNotifier {
  @override
  List<Item> build() {
    return ref.watch(itemDataProvider);
  }

  Item? byId(String id) {
    return state.firstWhereOrNull((element) => element.id == id);
  }

  List<Item> byIds(List<String> ids) {
    return state.where((itm) => ids.contains(itm.id)).toList();
  }
}
