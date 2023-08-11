import 'package:provider/provider.dart';

import 'container_service.dart';
import 'edit_custom_values/store_container_types.dart';
import 'store.dart';

ProxyProvider2 proxyContainerService() =>
    ProxyProvider2<Store, StoreContainerTypes, ContainerService>(
        update: (ctx, store, storeContainerTypes, prev) =>
            ContainerService(store, storeContainerTypes));
