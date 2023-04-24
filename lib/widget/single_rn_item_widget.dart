import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/sequental_build_model.dart';
import '../model/signes_model.dart';
import '../model/single_rn_item_model.dart';
import '../provider/rn_items_provider.dart';
import '../provider/sequentialbuild_provider.dart';
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
    SequentialBuildModel sequentialBuildModels =
    Provider.of<SequentialBuildProvider>(context, listen: true)
        .sequentialBuildModels
        .firstWhere((element) => element.id == rnItem.sequentialBuildId);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(3),
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rnItem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.clip),),
                Checkbox(
                  value: rnItem.checked,
                  onChanged: (bool? value) {
                    rnItem.checked = value!;
                    rnItemsProvider.updateRNItemInFB(rnItem);
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 61,
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
                          const Text("Amount", style: TextStyle(fontSize: 10),),
                          Text("${rnItem.amount} x"),
                        ],
                      ),
                      const SizedBox(width: 20,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Weight", style: TextStyle(fontSize: 10),),
                          Text("${rnItem.weight} kg"),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 180,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: rnItem.signeIDs
                            .map((e) => Container(
                          padding: const EdgeInsets.all(3.0),
                          width: 30,
                          height: 30,
                          child: Image.asset(
                              "assets/signes/${SignesModel().signes[e.toInt()]}"),
                        ))
                            .toList(),
                      ),
                    ),
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
