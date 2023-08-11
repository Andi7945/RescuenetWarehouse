import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/edit_custom_values/store_container_types.dart';

import 'rescue_container.dart';
import 'store.dart';

ProxyProvider2 proxyRescueContainer() =>
    ProxyProvider2<Store, StoreContainerTypes, List<RescueContainer>>(
        update: (ctx, store, storeContainerTypes, prev) => store.containerValues
            .map((e) =>
                RescueContainer.fromDao(e, storeContainerTypes.get(e.typeId)))
            .toList());
