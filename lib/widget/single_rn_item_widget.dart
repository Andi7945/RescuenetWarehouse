import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/single_rn_item_model.dart';
import '../provider/rn_items_provider.dart';
import '../utils/storage_util.dart';

class SingleRNItemWidget extends StatefulWidget {
  SingleRNItemWidget({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<SingleRNItemWidget> createState() => _SingleRNItemWidgetState();
}

class _SingleRNItemWidgetState extends State<SingleRNItemWidget> {
  @override
  Widget build(BuildContext context) {
    RNItemsProvider rnItemsProvider = Provider.of<RNItemsProvider>(context, listen: true);
    SingleRNItemModel rnItem = rnItemsProvider.rnItems.firstWhere((SingleRNItemModel element) => element.id == widget.id);
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Text(rnItem.name, style: const TextStyle(fontWeight: FontWeight.bold),),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 85,
                  child: StorageUtil().getItemImage(id: rnItem.id)),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Euro Crate", style: const TextStyle(fontSize: 10),),
                          Text(rnItem.euroCrate ?? "-"),
                        ],
                      ),
                      SizedBox(width: 20,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text("Comb. Weight", style: const TextStyle(fontSize: 10),),
                          Text("-"),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text("Module Destination", style: const TextStyle(fontSize: 10),),
                          Text(rnItem.moduleDestination ?? "-"),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Checked", style: const TextStyle(fontSize: 10),),
                          //checkbox
                          Checkbox(
                            value: rnItem.checked,
                            onChanged: (bool? value) {
                              rnItem.checked = value!;
                              rnItemsProvider.updateRNItemInFB(rnItem);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
