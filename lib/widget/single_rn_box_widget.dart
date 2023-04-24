import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../model/sequental_build_model.dart';
import '../model/signes_model.dart';
import '../model/single_rn_item_model.dart';
import '../provider/rn_items_provider.dart';
import '../provider/sequentialbuild_provider.dart';
import '../utils/storage_util.dart';

class SingleRNBoxWidget extends StatefulWidget {
  const SingleRNBoxWidget({Key? key, required this.id, required this.position, required this.wight})
      : super(key: key);
  final String id;
  final int position;
  final double wight;

  @override
  State<SingleRNBoxWidget> createState() => _SingleRNBoxWidgetState();
}

class _SingleRNBoxWidgetState extends State<SingleRNBoxWidget> {
  @override
  Widget build(BuildContext context) {
    RNItemsProvider rnItemsProvider =
        Provider.of<RNItemsProvider>(context, listen: true);
    if (widget.id == "1") {
      return Container(
        child: const Text("Unsorted"),
      );
    }
    SingleRNItemModel rnItem = rnItemsProvider.rnBoxes
        .firstWhere((SingleRNItemModel element) => element.id == widget.id);
    SequentialBuildModel sequentialBuildModels =
        Provider.of<SequentialBuildProvider>(context, listen: true)
            .sequentialBuildModels
            .firstWhere((element) => element.id == rnItem.sequentialBuildId);

    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.position.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Spacer(),
              Text(
                rnItem.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    overflow: TextOverflow.clip),
              ),
              const Spacer(),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              GestureDetector(
                onTap: () {
                  _showQRCodeDialog(context, rnItem);
                },
                child: Container(
                    padding: const EdgeInsets.all(5),
                    width: 70,
                    height: 85,
                    child: StorageUtil().getItemImage(id: rnItem.id)),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Euro Crate",
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(rnItem.euroCrate ?? "-"),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Comb. Weight",
                            style: TextStyle(fontSize: 10),
                          ),
                          Text("${widget.wight} kg"),
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
                                  width: 40,
                                  height: 40,
                                  child: Image.asset(
                                      "assets/signes/${SignesModel().signes[e.toInt()]}"),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: sequentialBuildModels.sequentialBuildColor,
                  //border if selected
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(4.0),
                width: 91,
                height: 45,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sequential build",
                        style: TextStyle(
                          fontSize: 6,
                        ),
                      ),
                      Text(
                        sequentialBuildModels.des!,
                        style: const TextStyle(
                          //color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    "Module Destination",
                    style: TextStyle(fontSize: 10),
                  ),
                  Text(rnItem.moduleDestination ?? "-"),
                ],
              ),
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
    );
  }

  void _showQRCodeDialog(BuildContext context, SingleRNItemModel box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(box.name),
          content: Row(
            children: [
              SizedBox(
                  width: 300,
                  height: 300,
                  child: StorageUtil().getItemImage(id: box.id)),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: QrImage(
                  data: box.id,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Schließen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
