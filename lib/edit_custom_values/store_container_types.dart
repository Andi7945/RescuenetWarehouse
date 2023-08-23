import 'package:rescuenet_warehouse/firebase_store.dart';

import '../container_type.dart';

class StoreContainerTypes extends FirebaseStore<ContainerType> {
  StoreContainerTypes()
      : super('container_types', (json) => ContainerType.fromJson(json));
}
