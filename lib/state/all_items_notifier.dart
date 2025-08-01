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
    
    // Subscribe to the stream and update state when data changes
    repository.watchItems().listen((items) {
      if (mounted) {
        state = items;
      }
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
