import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/provider/sequentialbuild_provider.dart';

import '../model/signes_model.dart';
import '../model/single_rn_item_model.dart';
import '../widget/image_picker_widget.dart';

class RNItemsProvider extends ChangeNotifier {
  List<SingleRNItemModel> _rnItems = [];
  List<SingleRNItemModel> _rnBoxes = [];
  static const String _firebasePath = 'items';

  List<SingleRNItemModel> get rnItems => _rnItems;
  List<SingleRNItemModel> get rnBoxes => _rnBoxes;

  //listen to all items in the firebase
  void listenToRNItemsFromFB() {
    FirebaseFirestore.instance
        .collection(_firebasePath)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      List<SingleRNItemModel> _rnIncome = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
              SingleRNItemModel.fromJson(e.data(), e.id))
          .toList();
      _rnItems = _rnIncome.where((element) => element.isBox == false).toList();
      _rnBoxes = _rnIncome.where((element) => element.isBox).toList();
      print("RNItems from Firebase: ${_rnItems.length}");
      print("RNBoxes from Firebase: ${_rnBoxes.length}");
      notifyListeners();
    });
  }

  //update the item in the firebase
  Future<void> updateRNItemInFB(SingleRNItemModel rnItem) async {
    await FirebaseFirestore.instance
        .collection(_firebasePath)
        .doc(rnItem.id)
        .update(rnItem.toJson());
  }

  // add new item so firebase
  Future<String> addRNItemToFB(SingleRNItemModel rnItem) async {
    final DocumentReference<Map<String, dynamic>> documentReference =
        await FirebaseFirestore.instance
            .collection(_firebasePath)
            .add(rnItem.toJson());
    _rnItems
        .add(SingleRNItemModel.fromJson(rnItem.toJson(), documentReference.id));
    return documentReference.id;
  }

  //update only Image Url
  Future<void> updateImageUrlInFB(String id, String imageUrl) async {
    await FirebaseFirestore.instance
        .collection(_firebasePath)
        .doc(id)
        .update({'imageUrl': imageUrl});
  }


  //Add new item Alert widow
  //all variables can be insert, also the images
  Future<void> addNewRNItem(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController euroCrateController = TextEditingController();
    TextEditingController moduleDestinationController = TextEditingController();
    TextEditingController amount = TextEditingController();
    TextEditingController weight = TextEditingController();
    ScrollController scrollController = ScrollController();
    bool isBox = false;
    ImageUploads imageUploads = ImageUploads(null);
    SignesModel signesModel = SignesModel();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            var sBProvider = Provider.of<SequentialBuildProvider>(context, listen: true);
            return AlertDialog(
              title: const Text('Add new item'),
              content: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                        ),
                      ),
                      imageUploads,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('This is a Box'),
                          Checkbox(
                            value: isBox,
                            onChanged: (bool? value) {
                              setState(() {
                                isBox = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      !isBox ? TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: amount,
                        decoration: const InputDecoration(
                          hintText: 'Amount',
                        ),
                      ):
                      TextField(
                        controller: euroCrateController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp("[0-9x]")),
                          FilteringTextInputFormatter.deny(',', replacementString: 'x')
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Euro Crate',
                          suffixText: "cm x cm x cm",//³
                        ),
                      ),
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,2})')),
                          FilteringTextInputFormatter.deny(',', replacementString: '.')
                        ],
                        controller: weight,
                        decoration: const InputDecoration(
                            hintText: 'Wight',
                            suffixText: "kg",
                        ),
                      ),
                      !isBox ? Container() : TextField(
                        controller: moduleDestinationController,
                        decoration: const InputDecoration(
                          hintText: 'Module Destination',
                        ),
                      ),
                      isBox ? Container() : signesModel.horizontalSelection(),
                      !isBox ? Container() : sBProvider.horizontalSelection(),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    SingleRNItemModel rnItem = SingleRNItemModel(
                      id: '',
                      //should be fine, because it will be added from FB
                      name: nameController.text,
                      euroCrate: isBox ? euroCrateController.text : null,
                      moduleDestination: isBox ? moduleDestinationController.text : null,
                      amount: !isBox ? int.parse(amount.text) : 1,
                      weight: double.parse(weight.text),
                      isBox: isBox,
                      signeIDs: signesModel.selected,
                      sequentialBuildId: sBProvider.getID(),
                    );
                    String id = await addRNItemToFB(rnItem);
                    String? path = await imageUploads.uploadFile(imageName: id);
                    if (path != null) {
                      await updateImageUrlInFB(id, path);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  void updateItemPosition({required String id, required String oldBoxId, required String newBoxId}) {
    if(oldBoxId == newBoxId) return;
    if(oldBoxId != "1"){
      final oldBox = _rnBoxes.firstWhere((element) => element.id == oldBoxId);
      oldBox.contains.remove(id);
      updateRNItemInFB(oldBox);
    }
    if(newBoxId != "1"){
      final newBox = _rnBoxes.firstWhere((element) => element.id == newBoxId);
      newBox.contains.add(id);
      updateRNItemInFB(newBox);
    }
    notifyListeners();
  }


}
