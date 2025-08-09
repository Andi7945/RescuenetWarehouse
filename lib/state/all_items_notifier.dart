import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rescuenet_warehouse/collection_extensions.dart';
import 'package:rescuenet_warehouse/repositories/repository_providers.dart';

import '../models/item.dart';

part 'all_items_notifier.g.dart';

@riverpod
class AllItemsNotifier extends _$AllItemsNotifier {
  @override
  List<Item> build() {
    final repository = ref.watch(itemRepositoryProvider);

    // Use ref.listen to properly manage the stream subscription
    final subscription = repository.watchItems().listen((items) {
      state = items;
    });

    // Dispose subscription when notifier is disposed
    ref.onDispose(() {
      subscription.cancel();
    });

    return [];
  }

  Item? byId(String id) {
    return state.firstWhereOrNull((element) => element.id == id);
  }

  List<Item> byIds(List<String> ids) {
    return state.where((itm) => ids.contains(itm.id)).toList();
  }
}
